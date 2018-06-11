require 'sinatra'
require 'sinatra/reloader'
require 'rest-client'
require 'json'
require 'nokogiri'
require 'csv'

get '/' do
    erb:index
end

get '/webtoon' do
    # 내가 받아온 웹툰 데이터를 저장할 배열 생성
    toons = []
    # 웹툰 데이터를 받아올 url파악 및 요청보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
    result = RestClient.get(url)
    # 응답으로 온 내용(JSON)을 해쉬형태로 바꾸기
    webtoons = JSON.parse(result)
    # 해쉬내에서 웹툰 리스트에 해당하는 부분(key가 data, data안에 value들이 각각 웹툰 정보) 순환하기
    webtoons["data"].each do |toon|
    # 필요한 부분을 분리해서 처음만든 배열에 push
        # 웹툰 제목
        title = toon["title"]
        # 웹툰 이미지 주소
        image = toon["thumbnailImage2"]["url"]
        # 웹툰을 볼 수 있는 주소
       link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}" # String interpolation
         # 필요한 부분을 분리해서 처음 만든 배열에 push
        toons << {"title" => title,
                  "image" => image,
                  "link" => link
        }
    end
    # 완성된 배열 중에서 3개의 웹툰만 랜덤 추출
    @daum_webtoon = toons.sample(3)
    erb :webtoon
end



get '/check_file' do
    # 파일이있니? 없으면 아래 실행 
    unless File.file?('./webtoon.csv') #if not에 해당 ==> unless : if 에서 false가 나와야 조건문 실행된다.
        puts "파일이 없습니다."
           # 크롤링 한 웹툰 데이터를 CSV에 삽입
        # 내가 받아온 웹툰 데이터를 저장할 배열 생성
        toons = []
        # 웹툰 데이터를 받아올 url파악 및 요청보내기
        url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
        result = RestClient.get(url)
        # 응답으로 온 내용(JSON)을 해쉬형태로 바꾸기
        webtoons = JSON.parse(result)
        # 해쉬내에서 웹툰 리스트에 해당하는 부분(key가 data, data안에 value들이 각각 웹툰 정보) 순환하기
        webtoons["data"].each do |toon|
        # 필요한 부분을 분리해서 처음만든 배열에 push
            # 웹툰 제목
            title = toon["title"]
            # 웹툰 이미지 주소
            image = toon["thumbnailImage2"]["url"]
            # 웹툰을 볼 수 있는 주소
            link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}" # String interpolation
            # 필요한 부분을 분리해서 처음 만든 배열에 push
            toons << [title, image,link]
        end
        # CSV 파일을 새로 생성하는 코드
        CSV.open('./webtoon.csv','w+') do |row|
           # 크롤링 한 웹툰 데이터를 CSV에 삽입
           toons.each_with_index do |toon, index|
               row << [(index+1), toon[0], toon[1], toon[2]]
           end
        end
        erb :check_file
    else
        # 존재하는 CSV파일을 불러오는 코드
        @webtoons = []
        CSV.open('./webtoon.csv','r+').each do |row|
           @webtoons << row
        end
        erb :webtoons
    end
end

# /board?name=3 표현식
get '/board' do
    puts params[:name]
end

# /board/3 표현식  #와일드카드
get '/board/:name' do
    #/board/1
    puts params[:name]
end