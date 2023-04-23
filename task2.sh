#!/usr/bin/env bash
function helpdocument {
    echo "=========================帮助文档========================="
    echo "-y                 ----统计不同年龄区间范围(20岁以下、[20-30]、30岁以上)的球员数量、百分比"
    echo "-p                 ----统计不同场上位置的球员数量、百分比"
    echo "-l                 ----统计名字最长的球员,名字最短的球员"
    echo "-s                 ----统计年龄最大的球员，年龄最小的球员"
    echo "-h                 ----帮助文档"
}

function AgeRange {
    awk -F "\t" '
        NR>1{                          #排除Age列标题本身
        if($6 >= 0 && $6 < 20) {count[1]++} 
        else if($6 >= 20 && $6 <= 30) {count[2]++} 
        else if($6 > 30) {count[3]++} 
        }
        END {
            sum=count[1]+count[2]+count[3];
            printf("球员年龄\t球员数量\t百分比\n");
            printf("%-10s %10d %15.2f%%\n","age<20",count[1],count[1]*100/sum);
            printf("%-10s %10d %15.2f%%\n","[20,30]",count[2],count[2]*100/sum);
            printf("%-10s %10d %15.2f%%\n","age>30",count[3],count[3]*100/sum);
        }' worldcupplayerinfo.tsv
}

function Position {
    awk -F "\t" '
        NR>1{
           count[$5]++;
           sum++;
        }
        END {
            printf("位置\t\t数量\t百分比\n")
            for(i in count){
                printf("%-10s\t%d\t%f%%\n",i,count[i],count[i]*100/sum);
            }
        }' worldcupplayerinfo.tsv
}

function MAXMINname {
    awk -F "\t" '
        BEGIN {maxlen=0;minlen=1000;}
        NR>1{
        name[$9]=length($9);
        if (length($9) > maxlen) {
            maxlen = length($9); 
            }
        
        else if (length($9) < minlen) {
            minlen = length($9); 
            }
        }
        END {
            for(i in name){
                if(length(i)==maxlen){
                maxval=i;
                printf("名字最长的球员是 %s\n",maxval);
                }
                else if(length(i)==minlen){
                minval=i;
                printf("名字最短的球员是 %s\n",minval);
                } 
            }
        }' worldcupplayerinfo.tsv
}

function MaxMinAge {
    awk -F "\t" '
        BEGIN {max=0;min=1000;}
        NR>1{
        name[$9]=$6;
        if ($6 > max) {
            max = $6; 
            }
        
        else if ($6 < min) {
            min = $6; 
            }
        }
        END {
            for(i in name){
                if(name[i]==max){
                printf("年龄最大的球员是 %s 他的年龄为 %d\n",i,max);
                }
                else if(name[i]==min){
                printf("年龄最小的球员是 %s 他的年龄为 %d\n",i,min);
                } 
            }
        }' worldcupplayerinfo.tsv
}


while getopts :yplsh opt
do
case ${opt} in
y)
    AgeRange 
    exit 0
;;
p)
    Position 
    exit 0
;; 
l)  
    MAXMINname 
    exit 0
;;
s)  
    MaxMinAge
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