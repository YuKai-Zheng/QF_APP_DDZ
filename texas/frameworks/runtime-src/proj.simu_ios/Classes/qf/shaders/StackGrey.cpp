/******************************************************
 * Program Assignment:  灰度滤镜算法
 * Author:              Lynn
 * Date:                2015/2/21  21:23
 * Description:         灰度心理学公式: Gray = R*0.299 + G*0.587 + B*0.114
 *****************************************************/

#include "StackGrey.h"


namespace shader {
namespace grey {

void doStackGrey(unsigned char* src,				///< input image data
                unsigned int w,					///< image width
                unsigned int h					///< image height
)
{
    unsigned char* ptr = src;
    for (int i = 0; i < w * h * 4; i += 4)
    {
        unsigned int gray = (ptr[0] * 114 + ptr[1] * 587 + ptr[2] * 299 + 500) / 1000 ;
        ptr[0] = gray;  //R
        ptr[1] = gray;  //G
        ptr[2] = gray;  //B
        ptr[3] = 255;   //A
        ptr += 4;
    }

}

}   /* namespace grey */
}   /* namespace shader */