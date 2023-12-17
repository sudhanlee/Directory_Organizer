#!/bin/bash

print_usage() {
    echo "Usage: bash organizer.sh <srcdir> <destdir> [-s style] [-e exclude_list] [-l log_file] [-d]"
    echo "  -s style     Specify the organization style (ext or date, default: ext)"
    echo "  -d           Delete original files after organizing"
    echo "  -l log_file  Generate a log file with details of moved files"
    echo "  -e exclude_list  Exclude specific file types or directories"
    echo "  -h           Display this help message"
    exit 1
}


#Generating logfile
log_gen() {
    echo "Excluded list: " >> $log_file
    IFS=',' read -ra exclude_array <<< "$exclude_list" # Logging excluded list
    for element in "${exclude_array[@]}"; do
        echo $element >> $log_file
    done

    direc=$(find $destdir -type d | wc -l)
    echo "Total Directory : $direc"
    file=$(find $destdir -type f | wc -l)
    echo "Total Files : $file"
    echo "Total Directory: $direc" >> $log_file
    echo "Total Files: $file" >> $log_file

}


#Organizing based on extension
organize_by_extension() {
    echo "Organizing files by extension..."

    find "$srcdir" -type f | while read -r file; do
        result=0
        if [[ $exclude -eq 1 ]]; then  #Checking for exclude flag
            exclude_files $file
        fi
        if [[ $result -eq 0 ]]; then

            extension="${file##*.}"
            if [ "$extension" == "zip" ]; then  # Indentifing zip file
                temp=$srcdir"zipfiles"
                unzip -q $file -d $temp
                tempsrc=$srcdir
                srcdir=$temp
                if [ -e "$log_file" ]; then
                    echo "$(date +"%Y-%m-%d %H:%M:%S"): Unzipped $file"  >> "$log_file"
                fi
                organize_by_extension # Recursive call to organize zip file content
            fi

            if [ "$extension" != "$file" ]; then
                dest_folder="$destdir$extension"
                mkdir -p "$dest_folder"

                dest_file="$dest_folder/$(basename "$file")"
                count=1
                while [ -e "$dest_file" ]; do  #Avoiding overlaping
                    dest_file="$dest_folder/$(basename "$file" .${extension})_$count.${extension}" 
                    count=$((count + 1))
                done
            else
                dest_folder="$destdir""NoExtension"
                mkdir -p "$dest_folder"

                dest_file="$dest_folder/$(basename "$file")"
                count=1
                while [ -e "$dest_file" ]; do
                    dest_file="$dest_folder/$(basename "$file")_$count"
                    count=$((count + 1))
                done

            fi
            if [[ $delete -eq 1 ]]; # Checking for delete flag
            then
                mv "$file" "$dest_file"
                echo "Moved: $file -> $dest_file"
            else
                cp "$file" "$dest_file"
                echo "Moved: $file -> $dest_file"
            fi
            if [ -e "$log_file" ]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S"): Moved $file to $dest_folder" >> "$log_file"
            fi
        fi
    done
    if [[ $delete -eq 1 ]];
    then
        find $srcdir -type d -empty -exec rmdir {} \; 2>>/dev/null
        rm -d $srcdir 2>>/dev/null
    fi

        echo "Organizing by extension completed."

    if [ -d "$temp" ]; then
        rm -r $temp
    fi
    srcdir=$tempsrc
}


# Organizing Based on Date
organize_by_date() {
    echo "Organizing files by creation date..."

    find "$srcdir" -type f | while read -r file; do
        result=0
        if [[ $exclude -eq 1 ]]; then
            exclude_files $file
        fi
        if [[ $result -eq 0 ]]; then

            creation_date=$(stat -c %y "$file" | cut -d ' ' -f1)
            extension="${file##*.}"
            if [ "$extension" == "zip" ]; then
                temp=$srcdir"zipfiles"
                unzip -q $file -d $temp
                tempsrc=$srcdir
                srcdir=$temp
                if [ -e "$log_file" ]; then
                    echo "$(date +"%Y-%m-%d %H:%M:%S"): Unzipped $file" >> "$log_file"
                fi
                organize_by_date
            fi
            

            dest_folder="$destdir$creation_date" #Creating directory based on date in destination place
            mkdir -p "$dest_folder"

            if [ "$extension" != "$file" ]; then
                dest_file="$dest_folder/$(basename "$file")"
                    count=1
                    while [ -e "$dest_file" ]; do
                        dest_file="$dest_folder/$(basename "$file" .${extension})_$count.${extension}"
                        count=$((count + 1))
                    done

            else
                dest_file="$dest_folder/$(basename "$file")"
                    count=1
                    while [ -e "$dest_file" ]; do
                        dest_file="$dest_folder/$(basename "$file" .${extension})_$count"
                        count=$((count + 1))
                    done

            fi
            if [[ $delete -eq 1 ]];
            then
                mv "$file" "$dest_file"
                echo "Moved: $file -> $dest_file"
            else
                cp "$file" "$dest_file"
                echo "Moved: $file -> $dest_file"
            fi
            if [ -e "$log_file" ]; then
                echo "$(date +"%Y-%m-%d %H:%M:%S"): Moved $file to $dest_folder" >> "$log_file"
            fi
        fi
    done

    if [[ $delete -eq 1 ]];
    then
        find $srcdir -type d -empty -exec rmdir {} \; 2>>/dev/null
        rm -d $srcdir 2>>/dev/null
    fi

    echo "Organizing by creation date completed."

    if [ -d "$temp" ]; then
        rm -r $temp
    fi
    srcdir=$tempsrc
}




exclude_files() {

    local string=$1

    # Split the exclude_list into an array based on commas
    IFS=',' read -ra exclude_array <<< "$exclude_list"

    for element in "${exclude_array[@]}"; do
        if [[ $string == *"$element"* ]]; then # Checking for string matches in exclude list
            result=1
            return 
        fi
    done
    result=0
    return


}


if [[ $1 == '' ]];then
    print_usage
    exit 1
elif [[ $2 == '' ]];then
    print_usage
    exit 1
fi

style="ext"

srcdir=$1
destdir=$2

if [ ! -d $srcdir ]; then
    echo "Source Directory does not exist!!!"
    exit 1
fi

if [ ! -d $destdir ]; then
    mkdir -p "$destdir"
    destdir="$destdir/"
fi

shift 2
while getopts ":s:e:l:h:d" opt; do
  case $opt in
    e)  
        exclude_list="$OPTARG"
        if [[ "$OPTARG" == "" ]];then
            print_usage
            exit 1
        fi
        exclude=1
    ;;
    s) 
        style="$OPTARG"
    ;;
    l)
        if [[ "$OPTARG" == '' ]];then
            print_usage
            exit 1
        fi
        l=1
        log_file="$OPTARG"
        touch $log_file
    ;;
    d)
        delete=1
    ;;
    h)
        print_usage
    ;;
    \?) echo "Invalid option: -$OPTARG"
        exit 1
    ;;
  esac
done



case "$style" in
    ext)
        organize_by_extension
        ;;
    date)
        organize_by_date
        ;;
    *)
        echo "Invaild style mode"
        print_usage
        exit 1
        ;;
esac

if [[ $l -eq 1 ]]; then
    log_gen
fi

exit 0