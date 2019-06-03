/******************************************************
 * Program Assignment:  图像模糊算法
 * Author:              Lynn
 * Date:                2015/2/20  22:20
 * Description:         高斯模糊滤镜效果,查表修改图像RAW,高效
 *****************************************************/

#ifndef __STACK_BLUR_H__
#define __STACK_BLUR_H__

namespace shader {
    namespace blur {
        void doStackblur(unsigned char* src,				///< input image data
                      unsigned int w,					///< image width
                      unsigned int h,					///< image height
                      unsigned int radius,				///< blur intensity (should be in 2..254 range)
                      unsigned char* stack				///< stack buffer
        );
    }
}

#endif /* __STACK_BLUR_H__ */
