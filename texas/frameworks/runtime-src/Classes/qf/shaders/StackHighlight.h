/******************************************************
 * Program Assignment:  高亮滤镜算法
 * Author:              Lynn
 * Date:                2015/3/19  23:40
 * Description:         RGB分量各加上统一的增量,向(255,255,255)偏转,实现简单的高亮效果
 *****************************************************/

#ifndef __STACK_HIGHTLIGHT_H__
#define __STACK_HIGHTLIGHT_H__

namespace shader {
    namespace highlight {
        void doStackHighlight(unsigned char* src,   ///< input image data
                         unsigned int w,            ///< image width
                         unsigned int h,            ///< image height
                         unsigned int increment,     ///< portion plus
                         int arg=4
        );
    }
}

#endif /* __STACK_HIGHTLIGHT_H__ */
