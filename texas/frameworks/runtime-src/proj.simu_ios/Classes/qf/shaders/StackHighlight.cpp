/******************************************************
 * Program Assignment:  高亮滤镜算法
 * Author:              Lynn
 * Date:                2015/3/19  23:40
 * Description:         RGB分量各加上统一的增量,向(255,255,255)偏转,实现简单的高亮效果
 *****************************************************/

#include "StackHighlight.h"


namespace shader {
    namespace highlight {
        
        void doStackHighlight(unsigned char* src,       ///< input image data
                         unsigned int w,                ///< image width
                         unsigned int h,                ///< image height
                         unsigned int increment         ///< portion plus

                )
        {
            unsigned char* ptr = src;
            for (int i = 0; i < w * h * 4; i += 4)
            {
                unsigned int r = ptr[0] + increment;
                unsigned int g = ptr[1] + increment;
                unsigned int b = ptr[2] + increment;
                ptr[0] = r > 255 ? 255 : r;
                ptr[1] = g > 255 ? 255 : g;
                ptr[2] = b > 255 ? 255 : b;
                ptr += 4;
            }
            
        }
        
    }   /* namespace highlight */
}   /* namespace shader */