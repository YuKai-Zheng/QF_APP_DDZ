#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <iostream>
#include <memory>
#include <sstream>
#include <algorithm>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <sstream>
#include <fstream>

#include "xxtea.h"

#define HEADER "[type1]"

void test_xxtea() {
    std::string key = "7f86fbe5bb8241b38ebe18323fd67558";
    std::string src = "I love you!";

    xxtea_long dst_len = 0;
    unsigned char* dst = xxtea_encrypt((unsigned char*)src.c_str(), src.size(), (unsigned char*)key.c_str(), key.size(), &dst_len);

    printf("dst_len: %d\n", dst_len);
    printf("dst: %s\n", dst);

    xxtea_long org_len = 0;
    unsigned char* org = xxtea_decrypt(dst, dst_len, (unsigned char*)key.c_str(), key.size(), &org_len);

    printf("org_len: %d\n", org_len);
    printf("org: %s\n", org);
}

std::string read_file(char* filename) {

    std::stringstream ss;
    std::ifstream fin(filename);

    if (fin) {
        ss << fin.rdbuf();
        fin.close();
        return ss.str();
    }

    return "";
}

int main(int argc, char **argv) {
    if (argc < 5) {
        printf("fail! please input: e/d key_filename src_filename dst_filename\n");
        return 0;
    }
    
    std::string type = argv[1];
    char* key_filename = argv[2];
    char* src_filename = argv[3];
    char* dst_filename = argv[4];

    std::string key = read_file(key_filename);
    if (key.empty()) {
        printf("fail! key_filename not exist or is empty\n");
        return 0;
    }

    std::string content = read_file(src_filename);
    if (content.empty()) {
        printf("fail! src_filename not exist or is empty\n");
        return 0;
    }
    // printf("%s\n", content.c_str());

    xxtea_long result_len = 0;
    unsigned char* result;
    if (type == "e") {
        result = xxtea_encrypt((unsigned char*)content.c_str(), content.size(),
                               (unsigned char*)key.c_str(), key.size(), &result_len);
    }
    else {
        result = xxtea_decrypt((unsigned char*)content.c_str() + strlen(HEADER), content.size() - strlen(HEADER),
                               (unsigned char*)key.c_str(), key.size(), &result_len);
    }

    // printf("result_len: %d\n", result_len);

    std::ofstream fout(dst_filename, std::ios::binary); 

    // 加密才需要写入文件
    if (type == "e") {
        fout.write(HEADER, strlen(HEADER));
    }

    fout.write((char*)result, result_len);

    fout.close();

    printf("succ!\n");
    return 0;
}
