# Directory Organizer

## Usage
**Usage: bash organizer.sh <srcdir> <destdir> [-s style] [-e exclude_list] [-l log_file] [-d]
  -s style     Specify the organization style (ext or date, default: ext)
  -d           Delete original files after organizing
  -l log_file  Generate a log file with details of moved files
  -e exclude_list  Exclude specific file types or directories
  -h           Display this help message**


## Command Format
`./organizer.sh <srcdir> <destdir> -s <style> -e <exclude_list> -l <log_file> -d`

### Example Commands

**Give Executable permission** \
`chmod +x organizer.sh`\
`./organizer.sh source/ destiny/ -s ext -e subdir_3,txt -l log.txt`

### Sample Output

**Input**
```
source/
├── a.png
├── a.txt
├── b.pdf
├── c.jpg
├── e.py
├── e.txt
├── subdir_1
│   └── j.txt
├── subdir_2
│   ├── g.png
│   ├── s.mp3
│   └── t.pdf
├── subdir_3
│   ├── l.pdf
│   ├── m.png
│   ├── script.c
│   └── x.py
└── zipped.zip

4 directories, 15 files
```

**Output**
```
destiny/
├── cpp
│   └── i.cpp
├── jpg
│   ├── c.jpg
│   └── d.jpg
├── mp3
│   └── s.mp3
├── pdf
│   ├── b.pdf
│   └── t.pdf
├── png
│   ├── a.png
│   ├── g.png
│   ├── y.png
│   └── z.png
├── py
│   └── e.py
└── zip
    └── zipped.zip

8 directories, 12 files
```
**Log file created**
`2023-12-17 10:10:23: Moved source/subdir_2/t.pdf to destiny//pdf\
2023-12-17 10:10:23: Moved source/subdir_2/s.mp3 to destiny//mp3\
2023-12-17 10:10:23: Moved source/subdir_2/g.png to destiny//png\
2023-12-17 10:10:23: Moved source/c.jpg to destiny//jpg\
2023-12-17 10:10:23: Moved source/e.py to destiny//py\
2023-12-17 10:10:23: Unzipped source/zipped.zip\
2023-12-17 10:10:23: Moved source/zipfiles/zipfolder/z.png to destiny//png\
2023-12-17 10:10:23: Moved source/zipfiles/zipfolder/i.cpp to destiny//cpp\
2023-12-17 10:10:23: Moved source/zipfiles/zipfolder/y.png to destiny//png\
2023-12-17 10:10:23: Moved source/zipfiles/zipfolder/d.jpg to destiny//jpg\
2023-12-17 10:10:23: Moved source/zipped.zip to destiny//zip\
2023-12-17 10:10:23: Moved source/a.png to destiny//png\
2023-12-17 10:10:23: Moved source/b.pdf to destiny//pdf\
Excluded list: \
subdir_3\
txt\
Total Directory: 8\
Total Files: 12`\
