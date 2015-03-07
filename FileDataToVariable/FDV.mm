//
//  FDV.cpp
//  FileDataToVariable
//
//  Created by DollStudio on 15/3/7.
//  Copyright (c) 2015年 DollStudio. All rights reserved.
//

#include "FDV.h"
#import <Foundation/Foundation.h>
#include <map>
#include <vector>

using namespace std;

FDV::FDV()
{
    
}

FDV::~FDV()
{
    
}

FDV* FDV::GetInstance()
{
    static FDV* s_instance = NULL;
    if (!s_instance) {
        s_instance = new FDV();
    }
    return s_instance;
}

void FDV::ConvertFToV(const std::string& directory)
{
    std::vector<std::string> paths;
    TraversalAllPath(directory,paths);
    vector<FDV_Data*> datas;
    for (const string& path : paths)
    {
        FDV_Data* data = GetFileData(directory,path);
        datas.push_back(data);
    }
    WriteVariable(directory,datas);
    for (FDV_Data* data : datas)
    {
        delete data;
    }
}

void FDV::WriteVariable(const  std::string& directory,const std::vector<FDV_Data*>& datas)
{
    //写.h文件
    string* ttext = new string();
    string& text = *ttext;
    text.append("//\n\
//  fdv_res.h\n\
//  FileDataToVariable\n\
//  该文件由FDV工具生成\n\
//  工具Git地址 https://github.com/DollStudio/FileDataToVariable\n\
//\n\
//\n\
\n\
#ifndef __FileDataToVariable__fdv_res__\n\
#define __FileDataToVariable__fdv_res__\n\
\n\
#include <stdio.h>\n\
#include <string>\n\
#include <vector>\n\
#include <map>\n\
\n\
namespace fdv\n\
{\n\
class FDV_Data\n\
{\n\
public:\n\
    FDV_Data():bytes(),size(0){}\n\
    ~FDV_Data(){if (bytes) {delete [] bytes;}}\n\
    const unsigned char* bytes;\n\
    size_t size;\n\
    std::string path;\n\
};\n\
extern const unsigned char* read_file(const char* path,long& length);\n\
}\n\
\n\
#endif /* defined(__FileDataToVariable__fdv_res__) */\n");
    
    FILE* file = fopen((directory+"fdv_res.h").c_str(), "w+");
    if (file) {
        fwrite(text.c_str(), text.length(), 1, file);
        fclose(file);
    }
    text.clear();
    
    text.append("//\n\
//  fdv_res.cpp\n\
//  FileDataToVariable\n\
//  该文件由FDV工具生成\n\
//  工具Git地址 https://github.com/DollStudio/FileDataToVariable\n\
//\n\
//\n\
\n\
#include \"fdv_res.h\"\n\
\n\
using namespace std;\n\
\n\
namespace fdv {\n\
static map<string, FDV_Data*> s_all_res;\n\n");
    int k=0;
    for (auto iter = datas.begin(); iter != datas.end(); ++iter,++k) {
        auto d1 = *iter;
#define t_name1 );text.append(d1->name);text.append(
        text.append("//");
        text.append(d1->path);
        text.append("\nstatic long fdv_len_" t_name1 "=");
        char buffer1[8];
        memset(buffer1, 0, 8);
        sprintf(buffer1, "%ld;\n",d1->size);
        text.append(buffer1);
        text.append("\
static const unsigned char fdv_" t_name1 "[]={");
        for (long i=0; i<d1->size; ++i)
        {
            memset(buffer1, 0, 8);
            sprintf(buffer1, "0x%x",*(d1->bytes+i));
            text.append(buffer1);
            if (i != d1->size-1) {
                text.append(",");
            }
            if (i % 16 == 0) {
                text.append("\n");
            }
        }
        text.append("\n};\n");
    }
    text.append("\
    \n\
    void init_fdv()\n\
    {\n\
        if (s_all_res.size() == 0) {\n\
            FDV_Data* filedata = NULL;\n");
    
    for (auto iter = datas.begin(); iter != datas.end(); ++iter,++k) {
        auto d1 = *iter;
        text.append("\
            filedata=new FDV_Data();\n\
            filedata->bytes=fdv_" t_name1 ";\n\
            filedata->size=fdv_len_" t_name1 ";\n\
            s_all_res[\"");
        text.append(d1->path);
        text.append("\"]=filedata;\n");
    }
    
    text.append("\
        }\n\
    }\n\
    \n\
    const unsigned char* read_file(const char* path,long& len)\n\
    {\n\
        init_fdv();\n\
        std::map<std::string,FDV_Data*>::iterator iter = s_all_res.find(path);\n\
        if (iter != s_all_res.end()) {\n\
            FDV_Data* data = iter->second;\n\
            len = data->size;\n\
            return data->bytes;\n\
        }\n\
        len = 0;\n\
        return NULL;\n\
    }\n\
    \n\
}\n");
    
    file = fopen((directory+"fdv_res.cpp").c_str(), "w+");
    if (file) {
        fwrite(text.c_str(), text.length(), 1, file);
        fclose(file);
    }
    
    delete ttext;
}

void FDV::TraversalAllPath(const  std::string& directory,std::vector<std::string>& paths)
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:[NSString stringWithUTF8String:directory.c_str()] error:nil]];
    for (NSString* str in tempFileList)
    {
        string path = str.UTF8String;
        for (const string& suffix : allSuffix)
        {
            if (path.find(suffix) != path.npos) {
                paths.push_back(path);
            }
        }
    }
}
void string_replace( std::string &strBig, const std::string &strsrc, const std::string &strdst )
{
    std::string::size_type pos = 0;
    std::string::size_type srclen = strsrc.size();
    std::string::size_type dstlen = strdst.size();
    
    while( (pos=strBig.find(strsrc, pos)) != std::string::npos )
    {
        strBig.replace( pos, srclen, strdst );
        pos += dstlen;
    }
}

FDV_Data* FDV::GetFileData(const std::string& directory,const std::string& path)
{
    FILE* file = fopen((directory+path).c_str(), "rb");
    if (file) {
        FDV_Data* data = new FDV_Data();
        fseek(file,0,SEEK_END);
        data->size = ftell(file);
        fseek(file,0,SEEK_SET);
        unsigned char* byte = new unsigned char[data->size+1];
        fread(byte,sizeof(unsigned char), data->size,file);
        byte[data->size] = '\0';
        data->bytes = byte;
        data->path = path;
        data->name = path;
        string_replace(data->name, "/", "_");
        string_replace(data->name, ".", "_");
        return data;
    }
    return NULL;
}
