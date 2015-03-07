//
//  FDV.h
//  FileDataToVariable
//
//  Created by DollStudio on 15/3/7.
//  Copyright (c) 2015年 DollStudio. All rights reserved.
//

#ifndef __FileDataToVariable__FDV__
#define __FileDataToVariable__FDV__

#include <stdio.h>
#include <vector>
#include <string>


class FDV_Data
{
public:
    FDV_Data():bytes(),size(0){}
    ~FDV_Data(){if (bytes) {delete [] bytes;}}
    unsigned char* bytes;
    size_t size;
    std::string path;
    std::string name;
};


class FDV {
    FDV();
    ~FDV();
public:
    static FDV* GetInstance();
    
    void ConvertFToV(const std::string& directory);
    void WriteVariable(const std::string& path,const std::vector<FDV_Data*>& datas);
    void TraversalAllPath(const std::string& directory,std::vector<std::string>& paths);
    FDV_Data* GetFileData(const std::string& directory,const std::string& path);
    std::vector<std::string> allSuffix;
};

#endif /* defined(__FileDataToVariable__FDV__) */
