#!/usr/bin/env python
#coding=utf8

import httplib
import urllib
import time
from socket import inet_ntoa
from struct import pack
import random
import json
import urllib2

HOST="voice.ihou.com"
PORT=80
METHOD="GET"
REQUEST_URL="/act/voice/vote?entryid=24"

COVERNAME='DearFriend'

#投票次数

def long2ip(ip):
    return inet_ntoa(pack("!L", ip))

def rand_ip():
    ip_long=[
        	['607649792', '608174079'],
            ['1038614528', '1039007743'],
            ['1783627776', '1784676351'],
            ['2035023872', '2035154943'],
            ['2078801920', '2079064063'],
            ['-1950089216', '-1948778497'],
            ['-1425539072', '-1425014785'],
            ['-1236271104', '-1235419137'],
            ['-770113536', '-768606209'],
            ['-569376768', '-564133889'],
    ]
    rand_key=random.randint(0,9)
    start=ip_long[rand_key][0]
    end=ip_long[rand_key][1]
    return long2ip(random.randint(int(start),int(end)))

def getVoteList():
    return json.load(urllib2.urlopen('http://voice.ihou.com/act/voice/getvotelist'))

def http_request(ip):
    #请求参数
    params=urllib.urlencode({
    'scope':'all',
    'q':'python',
    })
    #请求头
    headers={
     "Host":"voice.ihou.com",
     "Connection":"keep-alive",
     "Pragma":"no-cache",
     "Cache-Control":"no-cache",
     "X-Forwarded-For":ip,
     "Accept":"application/json, text/plain, */*",
     "User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.104 Safari/537.36",
     "Referer":"http://voice.ihou.com/act/voice/",
     "Accept-Encoding":"gzip,deflate,sdch",
     "Accept-Language":"zh-CN,zh;q=0.8",
     "Cookie": "__utma=102049753.1647956682.1414392637.1414392637.1414392637.1; __utmb=102049753.5.10.1414392637; __utmc=102049753; __utmz=102049753.1414392637.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)",
    }
    conn=httplib.HTTPConnection(HOST,PORT)
    conn.request(METHOD,REQUEST_URL,None,headers)
    response=conn.getresponse()
    data=response.read()
    if 'true' in data:
        print('success vote!')
    else:
        print('failed vote: switch ip please!')
    print(data)
    conn.close()
    return (response.status,response.reason,data)

def getMaxVote(jsondata):
    max=0
    converName=''
    gap=0
    for v in jsondata:
        num=v['VoteNo']
        cover=v['CoverName']
        if(max<num):
            max=num
            converName=cover
        if cmp(cover,COVERNAME)==0:
            gap=max-num

    return  max,converName,gap

def voteByCompetitor():
    data=getVoteList()
    voteNo,cover,gap=getMaxVote(data)
    if cmp(COVERNAME,cover)==0:
        return
    else:
        for i in range(0,gap+5):
            vote()

def vote():
     http_request(rand_ip())

def simpleVote():
	voteCount=2500
    while voteCount>0:
        try:
            vote()
        except:
            print('can not connect to server,try later!')
        time.sleep(0.2)
        voteCount=voteCount-1
    pass

if __name__ == '__main__' :
	simpleVote()
