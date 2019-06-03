/******************************************************
 * Program Assignment:  Action: 圆周运动
 * Author:              Lynn
 * Date:                2015/2/26  01:28
 * Description:         继承自cocos2d::ActionInterval
 *****************************************************/
#ifndef __MOVE_CIRCLE_H__
#define __MOVE_CIRCLE_H__

#include "cocos2d.h"


class MoveCircle : public cocos2d::ActionInterval
{
public:
    /*  创建一个圆周运动动作. duration: 时间; center, 圆心; degress, 旋转角度.  */
    static MoveCircle* create(float duration, const cocos2d::Vec2& center, float degress);
    
    virtual MoveCircle* clone() const override;
    virtual MoveCircle* reverse() const override;
    virtual void startWithTarget(cocos2d::Node *target) override;
    virtual void update(float t) override;

public:
    bool initWithDuration(float duration, const cocos2d::Vec2& center, float degress);
    
protected:
    cocos2d::Vec2 m_startPosition;
    cocos2d::Vec2 m_ptCenter;
    float m_duration;
    float m_fAngleDegress;
    float m_fAngleDelta;
#if CC_ENABLE_STACKABLE_ACTIONS
    float m_startRotation;
    float m_canRotate;
#endif

};

#endif // __MOVE_CIRCLE_H__
