/******************************************************
 * Program Assignment:  灰度滤镜算法
 * Author:              Lynn
 * Date:                2015/2/21  21:23
 * Description:         灰度心理学公式: Gray = R*0.299 + G*0.587 + B*0.114
 *****************************************************/

#ifndef __STACK_GREY_H__
#define __STACK_GREY_H__

namespace shader {
    namespace grey {
        void doStackGrey(unsigned char* src,				///< input image data
                         unsigned int w,					///< image width
                         unsigned int h,					///< image height
                         int arg=3
        );
    }
}

#endif /* __STACK_GREY_H__ */
