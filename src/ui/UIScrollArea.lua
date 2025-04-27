local class = require("lib.middleclass")
local UIElement = require("src.ui.UIElement")

local UIScrollArea = class("UIScrollArea", UIElement)

function UIScrollArea:initialize(x, y, width, height, borderPadding)
    UIElement.initialize(self, x, y, width, height)
    self.scrollY = 0
    self.scrollSpeed = 20
    self.contentHeight = height
    self.controls = {}
    self._isScrolling = false
    self.borderPadding = borderPadding or 10
    self.scrollBarWidth = 8
    self.scrollBarPadding = 2
    self.scrollBarColor = {0.6, 0.6, 0.6, 0.8}
    self.scrollBarActiveColor = {0.7, 0.7, 0.7, 1}
    self._scrollBarVisible = false
    self._scrollBarDragging = false
    self._scrollBarDragStartY = 0
    self._scrollBarDragStartScroll = 0
end

function UIScrollArea:clearControls()
    self.controls = {}
    self.scrollY = 0
    self:updateContentHeight()
end

function UIScrollArea:withScissor(func)
    love.graphics.setScissor(self._absX, self._absY, self.width, self.height)
    func()
    love.graphics.setScissor()
end

function UIScrollArea:draw()
    -- Draw background
    love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
    love.graphics.rectangle("fill", self._absX, self._absY, self.width, self.height)

    -- Draw content with scissor
    self:withScissor(function()
        love.graphics.push()
        love.graphics.translate(0, -self.scrollY)

        -- Draw controls
        for _, control in ipairs(self.controls) do
            if control.draw then
                love.graphics.push()
                love.graphics.translate(self._absX + control.x, self._absY + control.y)
                control:draw()
                love.graphics.pop()
            end
        end

        love.graphics.pop()
    end)

    -- Draw scrollbar if needed
    if self._scrollBarVisible then
        local scrollBarHeight = math.max(20, self.height * (self.height / self.contentHeight))
        local scrollBarPos = (self.scrollY / (self.contentHeight - self.height)) * (self.height - scrollBarHeight)
        
        love.graphics.setColor(self._scrollBarDragging and self.scrollBarActiveColor or self.scrollBarColor)
        love.graphics.rectangle(
            "fill",
            self._absX + self.width - self.scrollBarWidth - self.scrollBarPadding,
            self._absY + scrollBarPos + self.scrollBarPadding,
            self.scrollBarWidth,
            scrollBarHeight - 2 * self.scrollBarPadding,
            4
        )
    end
end

function UIScrollArea:touchpressed(id, x, y)
    local localX = x - self._absX
    local localY = y - self._absY

    -- Check scrollbar click first
    if self._scrollBarVisible and localX > self.width - self.scrollBarWidth - 2 * self.scrollBarPadding then
        self._scrollBarDragging = true
        self._scrollBarDragStartY = y
        self._scrollBarDragStartScroll = self.scrollY
        return true
    end

    -- Check controls
    for i = #self.controls, 1, -1 do
        local control = self.controls[i]
        local controlX = self._absX + control.x
        local controlY = self._absY + control.y - self.scrollY
        
        if control.isInside and control:isInside(x - controlX, y - controlY) then
            if control.touchpressed then
                return control:touchpressed(id, x - controlX, y - controlY)
            end
        end
    end

    -- Start scrolling if nothing else was clicked
    self._isScrolling = true
    return true
end

function UIScrollArea:touchmoved(id, x, y, dx, dy)
    if self._scrollBarDragging then
        local deltaY = y - self._scrollBarDragStartY
        local scrollRatio = deltaY / (self.height - (self.height * (self.height / self.contentHeight)))
        self.scrollY = math.max(0, math.min(
            self._scrollBarDragStartScroll + scrollRatio * (self.contentHeight - self.height),
            self.contentHeight - self.height
        ))
        return true
    elseif self._isScrolling then
        self.scrollY = math.max(0, math.min(self.scrollY - dy, self.contentHeight - self.height))
        return true
    end
    return false
end

function UIScrollArea:touchreleased(id, x, y)
    self._isScrolling = false
    self._scrollBarDragging = false
    
    -- Notify controls if needed
    for _, control in ipairs(self.controls) do
        if control.touchreleased then
            control:touchreleased(id, x - self._absX - control.x, y - self._absY - control.y + self.scrollY)
        end
    end
    
    return true
end

function UIScrollArea:updateContentHeight()
    local maxY = 0
    for _, control in ipairs(self.controls) do
        maxY = math.max(maxY, control.y + control.height)
    end
    self.contentHeight = math.max(maxY, self.height)
    self._scrollBarVisible = self.contentHeight > self.height
end

function UIScrollArea:addControl(control)
    table.insert(self.controls, control)
    self:updateContentHeight()
end

return UIScrollArea