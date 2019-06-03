
ModuleManager = {}

local globalModule = import(".global.GlobalController")
local activityModule = import(".activity.ActivityController")
local popularizeModule = import(".popularize.PopularizeController")
local rankModule = import(".rank.RankController")
local rewardModule = import(".reward.RewardController")
local focaTaskModule = import(".focaTask.FocaTaskController")
local settingModule = import(".setting.SettingController")
local shopModule = import(".shop.ShopController")
local loginModule = import(".login.LoginController")
local changeUserModule = import(".change_userinfo.ChangeUserInfoController")
local daojuModule = import(".daoju.DaojuController")
local shareModule = import(".share.ShareController")
local preloadModule = import(".preload.PreloadController")--预加载控制器
local focasModule = import(".focas.FocasController")--奖券
local matchingModule = import(".matching.MatchingController")--比赛一级界面
local BoradcastModule = import(".boradcast.BoradcastController")--跑马灯界面
local exchangeMallModule = import(".exchange.ExchangeMallController")--兑换商城

local gameshall       = import(".main.MainController")

local ddzhall           = import(".hall.HallController")

local EventGameController = import(".game.eventgame.EventGameController")
local NormalGameController = import(".game.normalgame.NormalGameController")

local TuiGuangController = import(".tuiguang.TuiGuangController")

ModuleManager.__moduleTable = {}

function ModuleManager:init ()

    self._controllers = {}
    self._moduleStack = {}

    self._controllers["global"] = globalModule.new()
    self.global = self._controllers["global"]

    self._controllers["activity"] = activityModule.new()
    self.activity = self._controllers["activity"]

    self._controllers["popularize"] = popularizeModule.new()
    self.popularize = self._controllers["popularize"]

    self._controllers["rank"] = rankModule.new()
    self.rank = self._controllers["rank"]

    self._controllers["prize"] = rewardModule.new()
    self.prize = self._controllers["prize"]

    self._controllers["focaTask"] = focaTaskModule.new()
    self.focaTask = self._controllers["focaTask"]

    self._controllers["setting"] = settingModule.new()
    self.setting = self._controllers["setting"]

    self._controllers["shop"] = shopModule.new()
    self.shop = self._controllers["shop"]

    self._controllers["change_userinfo"] = changeUserModule.new()
    self.change_userinfo = self._controllers["change_userinfo"]

    self._controllers["daoju"] = daojuModule.new()
    self.daoju = self._controllers["daoju"]

    self._controllers["share"] = shareModule.new()
    self.share = self._controllers["share"]

    self._controllers["preload"] = preloadModule.new()
    self.preload = self._controllers["preload"]

    self._controllers["login"] = loginModule.new()
    self.login = self._controllers["login"]

    self._controllers["focas"] = focasModule.new()
    self.focas = self._controllers["focas"]

    self._controllers["matching"] = matchingModule.new()
    self.matching = self._controllers["matching"]

    self._controllers["boradcast"] = BoradcastModule.new()
    self.boradcast = self._controllers["boradcast"]

    self._controllers["exchange"] = exchangeMallModule.new()
    self.exchange = self._controllers["exchange"]

    self._controllers["gameshall"] = gameshall.new()
    self.gameshall = self._controllers["gameshall"]

    self._controllers["DDZhall"] = ddzhall.new()
    self.DDZhall = self._controllers["DDZhall"]

    self._controllers["tuiguang"] = TuiGuangController.new()
    self.tuiguang = self._controllers["tuiguang"]

    self.cancelTable = {--除了global层之外其他的都要移除的table
        "game", "activity","popularize","focas","matching",
        "main","prize","setting","shop","lobby",
        "change_userinfo", "rank","customize","gamesRecord","chosehall","focaTask",
        "exchange"
    }

    qf.event:addEvent(ET.MODULE_SHOW,function ( args )
        if args == nil then return end
        self.__moduleTable[args] = true
        if table.indexof(self._moduleStack, args) ~= false then
            table.remove(self._moduleStack, table.indexof(self._moduleStack, args))
        end
        table.insert(self._moduleStack, args)
    end)

    qf.event:addEvent(ET.MODULE_HIDE,function ( args )
        if args == nil then return end
        self.__moduleTable[args] = false
        if table.indexof(self._moduleStack, args) ~= false then
            table.remove(self._moduleStack, table.indexof(self._moduleStack, args))
        end
    end)

    qf.event:addEvent(ET.APPLICATION_RESUME_NOTIFY, handler(self, self.handlerBackFromBlank))

    self._stack = {}
    self._stack_num = 0;
    self._uniques = {game = {"normal", "event"}}
end

function ModuleManager:getTopModuleName()
    return self._moduleStack[#self._moduleStack]
end

function ModuleManager:judegeIsIngame()
    if self.__moduleTable["game"]
        or self.__moduleTable["game_ddz"] then
        return true
    else
        return false
    end
end

function ModuleManager:judgeInMatch()
        return false
    end

function ModuleManager:judgeIsInNormalGame()
    if self.__moduleTable["game"] then
        return true
    else
        return false
    end
end

function ModuleManager:judegeIsInShop()
    return self.__moduleTable ~= nil and self.__moduleTable["shop"] or false
end

function ModuleManager:judegeIsInLogin()
    if self.__moduleTable["login"]  then
        return true
    else
        return false
    end
end

function ModuleManager:judegeIsInMain()
    local value = false    
     if self.__moduleTable["gameshall"]  then
     	value = true
     end

    return value
end

function ModuleManager:removeByCancellation()
    for k , v in pairs(self.cancelTable) do
        if self[v] then
            self[v]:remove()
        end
    end
end

function ModuleManager:removeExistView()
    for k,v in pairs(self.__moduleTable) do
        if v == true and self[k] then
            self[k]:remove()
        end
    end
    self.gameshall:remove()
    self.global:removeExistView()
end

function ModuleManager:handlerBackFromBlank( ... )
    self.gameshall:backFromBlank()
end

function ModuleManager:judegeIsInHall(  )
    local value = false    
    if self.__moduleTable["gameshall"]  then
        value = true
    end
    
    return value
end

function ModuleManager:get( name )
    return self._controllers[name]
end

--检查给定的name是否在unique列表中
function ModuleManager:getUniqueName( name )
    local found_name = ""
    for uni_name in ipairs(self._uniques) do
        if table.keyof(self._uniques[uni_name], name) then
            found_name = uni_name
            break
        end
    end

    return found_name
end

function ModuleManager:createController( name )
    local controller
    if self._controllers["game"] then
        if self._controllers["game"].Name == name then
            return self._controllers["game"]
        else
            self:remove("game")
        end
    end
    if name == "normal" then
        controller = NormalGameController.new()
    elseif name == "event" then
        controller = EventGameController.new()
    end

    return controller
end

--[[
显示某一视图模块
name 待显示的模块名称
params 传给视图的参数
cleanly 显示视图之前是否要清理其他已打开的视图
--]]
function ModuleManager:show( name, params, cleanly )
    if cleanly then
        self:clean()
    end

    local controller = self._controllers[name]

    --如果name在unique列表中，则要创建一个
    if self:getUniqueName(name) then
        controller = self:createController(name)
        name = "game"
        self._controllers[name] = controller
    end

    if not controller then
        loge("[ModuleManager] Not Found: ", name, " Controller")
        return;
    end

    controller:show(params)

    table.insert(self._stack, name)
    self._stack_num = self._stack_num + 1;
end

--隐藏除了栈顶视图之外的其他所有视图
function ModuleManager:hide( ... )
    local controller
    for i = 1, #self._stack - 1 do
        controller = self._controllers[self._stack[i]]
        if controller then
            controller:hide()
        end
    end
end

--移除某一视图模块
function ModuleManager:remove( name )
    local controller = self._controllers[name]

    if not controller then
        loge("[ModuleManager] Not Found: ", name, " Controller")
        return
    end

    controller:remove()

    for i = 1, self._stack_num do
        if self._stack[i] == name then
            if i == self._stack_num - 1 and i ~= 1 then
                controller = self._controllers[self._stack[i - 1]]
                if controller then
                    controller:display()
                end
            end

            if self:getUniqueName(name) then
                self._controllers[name] = nil
            end

            table.remove(self._stack, i)
            self._stack_num = self._stack_num - 1
        end
    end
end

--移除所有的视图模块
function ModuleManager:clean( ... )
    local name, controller
    while(self._stack_num > 0) do
        name = table.remove(self._stack)
        controller = self._controllers[name]
        if controller then
            controller:remove()
        end

        if self:getUniqueName(name) then
            this._controllers[name] = nil
        end
    end

    self._stack = {}
end

--移除除牌桌之外的所有场景
function ModuleManager:removeExistViewWithOutGame(name, paras)
    
end

--移除除主界面和传入场景外所有场景
function ModuleManager:removeExistViewWithOut(name)
    for k,v in pairs(self.__moduleTable) do
        if v == true and self[k] then
            dump(k)
            if k ~= "gameshall" and k ~= name then
                self[k]:remove()
            end
        end
    end
    self.global:removeExistView()
end