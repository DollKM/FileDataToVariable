//
//  main.cpp
//  FileDataToVariable
//
//  Created by DollStudio on 15/3/7.
//  Copyright (c) 2015年 DollStudio. All rights reserved.
//

#include <iostream>
#include <string>
#include <unistd.h>
#include "FDV.h"

using namespace std;


int main(int argc, const char * argv[]) {
    // insert code here...
    std::string path;
    
    std::cout << "************\n******本工具暂时只适合Mac平台******\n本工具能够将文件转换成字符数组，以做到将图片连同代码一同编译进工程这样的事情\n指令:\n\tsfx:只转换这个指令指定后缀的文件\n\t\t例如:sfx *.png *.jpg *.txt\n\texit: 退出\n\t如果你输入的是某个文件夹路径，该文件夹下所有后缀名符合的文件都会被替换\n\n请输入:" << std::endl;
    bool is_sfx = false;
    while (true)
    {
        std::cin >> path;
        if (is_sfx) {
            if (path.find("*.") == 0)
            {
                std::cout << "添加可转换的后缀名:" << path << endl;
                FDV::GetInstance()->allSuffix.push_back(path.substr(1));
                path.clear();
                continue;
            }
            else
            {
                is_sfx = false;
            }
        }
        if (path == "exit")
        {
            is_sfx = false;
            break;
        }
        else if (path.find("sfx") == 0)
        {
            is_sfx = true;
            FDV::GetInstance()->allSuffix.clear();
        }
        else if (path[0] == '/')
        {
            is_sfx = false;
            if (FDV::GetInstance()->allSuffix.size() == 0)
            {
                std::cout << "请指定转换的后缀名" << std::endl;
                path.clear();
                continue;
            }
            if (path[path.size()-1] != '/') {
                path.push_back('/');
            }
            if (access(path.c_str(),0) == -1)
            {
                std::cout << path << "不是文件夹，或未找到" << std::endl;
                path.clear();
                continue;
            }
            std::cout << "转换文件成代码中...输出的路径为:" << path << std::endl;
            FDV::GetInstance()->ConvertFToV(path.c_str());
            std::cout << "转换成功..." << std::endl;
        }
        else
        {
            std::cout << "无效的指令，请确认是否为全路径" << std::endl;
        }
        
        path.clear();
    }
    return 0;
}
