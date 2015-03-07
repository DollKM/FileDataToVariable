//
//  main.cpp
//  FileDataToVariable
//
//  Created by DollStudio on 15/3/7.
//  Copyright (c) 2015年 DollStudio. All rights reserved.
//

#include <iostream>
#include <istream>
#include <string>
#include <sstream>
#include <unistd.h>
#include "FDV.h"

using namespace std;

int main(int argc, const char * argv[]) {
    // insert code here...
    
    std::cout << "************\n******本工具暂时只适合Mac平台******\n本工具能够将文件转换成字符数组，以做到将图片连同代码一同编译进工程这样的事情\n指令:\n\tsfx:只转换这个指令指定后缀的文件\n\t\t例如:sfx *.png *.jpg *.txt\n\texit: 退出\n\t如果你输入的是某个文件夹路径，该文件夹下所有后缀名符合的文件都会被替换\n\n请输入:" << std::endl;
    while (true)
    {
        char buf[1024];
        memset(buf, 0, 1024);
        std::cin.getline(buf, 1024);
        
        std::string path = buf;
        if (path == "") {
            std::cin.clear();
            std::cin.sync();
            continue;
        }
        if (path == "exit")
        {
            break;
        }
        else if (path.find("sfx ") == 0)
        {
            stringstream ss(path);
            string sub;
            FDV::GetInstance()->allSuffix.clear();
            while(getline(ss,sub,' '))// ',' 是切割字符
            {
                if(sub.empty() || sub == "sfx")continue;
                sub.erase(0, sub.find_first_not_of(" /t/n/r"));// 去掉前面多余的空格
                sub.erase(sub.find_last_not_of(" /t/n/r")+1);// 去掉后面多余的空格
                std::cout << "添加转换的后缀名" << sub << std::endl;
                FDV::GetInstance()->allSuffix.push_back(sub.substr(1));
            }
        }
        else if (path[0] == '/')
        {
            if (FDV::GetInstance()->allSuffix.size() == 0)
            {
                std::cout << "请指定转换的后缀名" << std::endl;
                std::cin.clear();
                std::cin.sync();
                continue;
            }
            if (path[path.size()-1] != '/') {
                path.push_back('/');
            }
            if (access(path.c_str(),0) == -1)
            {
                std::cout << path << "不是文件夹，或未找到" << std::endl;
                std::cin.clear();
                std::cin.sync();
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
        std::cin.clear();
        std::cin.sync();
    }
    return 0;
}
