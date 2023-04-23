#!/usr/bin/env bash
function help {
    echo "=========================帮助文档========================="
    echo "-a                 ----统计访问来源主机TOP 100和分别对应出现的总次数"
    echo "-b                 ----统计访问来源主机TOP 100 IP和分别对应出现的总次数"
    echo "-c                 ----统计最频繁被访问的URL TOP 100"
    echo "-d                 ----统计不同响应状态码的出现次数和对应百分比"
    echo "-4                 ----分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
    echo "-e url             ----给定URL输出TOP 100访问来源主机"               
    echo "-h                 ----帮助文档"
}

function top100_host {
    printf "   %s  %s\n" "次数" "top100主机名" 
    awk -F "\t" '
    NR>1 {
        {print $1}
    }' web_log.tsv | sort | uniq -c | sort -g -k 1 -r | head -100
}

function top100_ip {
    printf "%s\t%14s\n" "top100IP地址" "次数"
    awk -F "\t" '
    NR>1 {
        if($1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/){
            ip[$1]++;
        }
    }
    END {
        for(i in ip){
            printf("%-20s\t%d\n",i,ip[i])
        }
    }' web_log.tsv | sort -g -k 2 -r | head -100
}

function top100_url {
    printf "   %s  %s\n" "次数" "URLtop100" 
    awk -F "\t" '
    NR>1 {
        {print $5}
    }' web_log.tsv | sort | uniq -c | sort -g -k 1 -r | head -100
}

function response {
    awk -F "\t" '
    BEGIN {
        printf("状态码\t次数\t百分比\n");
    }
    NR>1 {
        response[$6]++;
    }
    END {
        for(i in response){
            printf("%d\t%d\t%f%%\n",i,response[i],response[i]*100/(NR-1));
        }
    }' web_log.tsv
}

function 4xxresponse {
    printf "%s\t%38s\n" "URL(response=403 )" "次数"
    awk -F "\t" '
    NR>1 {
        if($6==403){
            url[$5]++;
        }
    }
    END {
        for(i in url){
            printf("%-50s\t%d\n",i,url[i]);
        }
    }' web_log.tsv | sort -g -k 2 -r | head -10
    echo "------------------------------------------------------------"
    printf "%s\t%38s\n" "URL(response=404 )" "次数"
    awk -F "\t" '
    NR>1 {
        if($6==404){
            url[$5]++;
        }
    }
    END {
        for(i in url){
            printf("%-50s\t%d\n",i,url[i]);
        }
    }' web_log.tsv | sort -g -k 2 -r | head -10
}

function inputurl {
    printf "%s\t%45s\n" "top100主机名" "次数"
    awk -F "\t" '
    NR>1 {
        if(flag==$5){
            host[$1]++;
        }
    }
    END {
        for(i in host){
            printf("%-50s\t%d\n",i,host[i]);
        }
    }' flag="${1}" web_log.tsv | sort -g -k 2 -r | head -100
}



while getopts :abcd4e:h opt
do
case ${opt} in
a)
    top100_host
    exit 0
;;
b)
    top100_ip
    exit 0
;; 
c)  
    top100_url
    exit 0
;;
d)  
    response
    exit 0
;;
4)  
    4xxresponse
    exit 0
;;
e)  
    inputurl "${OPTARG}"
    exit 0
;;
h)  
    helpdocument
    exit 0
;;
*) 
    echo "error" >&2
    exit 1 ;;
esac
done