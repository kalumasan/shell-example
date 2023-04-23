#! /bin/usr/env bash

function helpdocument {
    echo "=========================Command========================="
    echo "-q value                 ----对jpeg格式图片进行图片质量压缩"
    echo "-r R%                     ----对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩成R分辨率"
    echo "-w font_size color text  ----对图片批量添加自定义文本水印"
    echo "-p text                  ----统一添加文件名前缀，不影响原始文件扩展名"
    echo "-s text                  ----统一添加文件名后缀，不影响原始文件扩展名"
    echo "-t                       ----将png/svg图片统一转换为jpg格式图片"
    echo "-h                       ----帮助文档"
}

function QualityCompress {
    opt="$1"
    for f in * ; do
    filetype=${f##*.} #获取文件后缀 
    if [[ ${filetype} == "jpeg" ]];then 
    convert "${f}" -quality "${opt}" "${f}"
    echo "${f}has been compressed in quality!"
    fi     
    done 
}

function ResizeCompress {
    opt="$1" #获取压缩分辨率
    for f in * ; do
        filetype=${f##*.} #获取文件后缀
        if [[ ${filetype} == "jpeg" || ${filetype} == "png" || ${filetype} == "svg" ]];then 
        convert "${f}" -resize "${opt}" "${f}"
        echo "${f}已经压缩为${opt}分辨率"
        fi
    done
}

function Watermark {
    font_size="$1" #获取文本大小
    text_color="$2" #获取字体颜色
    text="$3" #获取文本内容
    for f in *; do
        filetype=${f##*.}
        if [[ ${filetype} == "jpeg" || ${filetype} == "png" || ${filetype} == "svg" ]];then
        convert -fill "${text_color}" -pointsize "${font_size}"  -draw "text 10,0 '${text}'" -gravity NorthWest "${f}" "${f}"
        echo "${f}成功加入文本水印" 
        fi
    done
}

function AddPrefix {
    text="${1}"
    for f in *; do
        filetype=${f##*.}
        if [[ ${filetype} == "jpeg" || ${filetype} == "png" || ${filetype} == "svg" ]];then
        mv "${f}" "${text}""${f}"
        echo "${f}成功添加前缀${text}"
        fi
    done
}


function AddSuffix {
    text="${1}"
    for i in *; do
        type=${i##*.}
        if [[ ${type} == "jpeg" || ${type} == "png" || ${type} == "svg" ]];then 
        filename2=${i%.*}${text}"."${type}
        mv "${i}" "${filename2}"
        echo "${i}已经添加后缀${text}"
        fi
    done
}

function ConvertFormat {
    for i in *; do
        type=${i##*.}
        if [[ ${type} == "png"||${type} == "svg"  ]];then 
        new_file1=${i%%.*}".jpg"
        convert "${i}" "${new_file1}"
        echo "${i}已经转换为jpg格式"
        fi
    done
}



while getopts :q:r:w:p:s:th opt
do
case ${opt} in
q)
    QualityCompress "${OPTARG}"
    exit 0
;;
r)
    ResizeCompress "${OPTARG}"
    exit 0
;; 
w)  
    Watermark "${OPTARG}" "$3" "$4" 
    exit 0
;;
p)  
    AddPrefix "${OPTARG}"
    exit 0
;;
s)  
    AddSuffix "${OPTARG}" 
    exit 0
;;
t)  
    ConvertFormat
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


