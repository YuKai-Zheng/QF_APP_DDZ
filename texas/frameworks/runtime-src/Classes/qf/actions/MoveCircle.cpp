/******************************************************
 * Program Assignment:  Action: 圆周运动
 * Author:              Lynn
 * Date:                2015/2/26  01:28
 * Description:         继承自cocos2d::ActionInterval
 *****************************************************/
#include "MoveCircle.h"
#include <string.h>

USING_NS_CC;

#define MOVE_CIRCLE_DEBUG 0

MoveCircle* MoveCircle::create(float duration, const cocos2d::Vec2& center, float degress)
{
    MoveCircle *moveCircle = new MoveCircle();
    moveCircle->initWithDuration(duration, center, degress);
    moveCircle->autorelease();
    return moveCircle;
}

bool MoveCircle::initWithDuration(float duration, const cocos2d::Vec2& center, float degress)
{
    if (ActionInterval::initWithDuration(duration))
    {
        m_duration = duration;
        m_ptCenter= center;
        m_fAngleDegress = degress;
        m_fAngleDelta= CC_DEGREES_TO_RADIANS(degress);  //角度换算为弧度
        return true;
    }
    return false;
}

MoveCircle* MoveCircle::clone() const
{
    auto a = new MoveCircle();
    a->initWithDuration(m_duration, m_ptCenter, m_fAngleDegress);
    a->autorelease();
    return a;
}

MoveCircle* MoveCircle::reverse() const
{
    return MoveCircle::create(m_duration, m_ptCenter, -m_fAngleDelta);
}

void MoveCircle::startWithTarget(Node *pTarget)
{
    ActionInterval::startWithTarget(pTarget);
    m_startPosition = pTarget->getPosition();
#if CC_ENABLE_STACKABLE_ACTIONS
    m_startRotation = pTarget->getRotation();
    if (strcmp(typeid(*pTarget).name(), typeid(Sprite).name()) == 0)    //只有sprite需要旋转
    {
        m_canRotate = true;
    }
#endif
}

void MoveCircle::update(float time)
{
    if (_target)
    {
        //根据起始点、圆心、弧度计算target当前帧位置
        Vec2 newPos = m_startPosition.rotateByAngle(m_ptCenter, m_fAngleDelta*time);
        _target->setPosition(newPos);
#if CC_ENABLE_STACKABLE_ACTIONS
        //旋转，按起始方向指向圆心
        if (m_canRotate)
        {
            float newRotation = m_startRotation - m_fAngleDegress * time;
            _target->setRotation(newRotation);
        }
#endif
        
#if MOVE_CIRCLE_DEBUG > 0
        DrawNode *center = DrawNode::create();
        center->drawDot(m_ptCenter, 10, Color4F::RED);
        _target->getParent()->addChild(center);
        
        cocos2d::log("%03f", time);
        DrawNode *trail = DrawNode::create();
        trail->drawDot(newPos, 3, Color4F::YELLOW);
        _target->getParent()->addChild(trail);
#endif
    }
}

