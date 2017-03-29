QuickInputMenu = QuickInputMenu or class()
QuickInputMenu._menu_id_key = "quick_input_menu_id_"
QuickInputMenu._menu_id_index = 0

function QuickInputMenu:new( ... )
	return self:init( ... )
end

function QuickInputMenu:init( title, text, user_text, options, show_immediately, config )

	QuickInputMenu._menu_id_index = QuickInputMenu._menu_id_index + 1
	self.dialog_data = {
		id = QuickInputMenu._menu_id_key .. tostring( QuickInputMenu._menu_id_index ),
		title = title,
		text = text,
		user_text = user_text or "",
		button_list = {},
	}

	if config then
		for k, v in pairs(config) do
			self.dialog_data[k] = self.dialog_data[k] or v
		end
	end

	self.visible = false

	local add_default = false
	if (not options) or (options ~= nil and type(options) ~= "table") or (options ~= nil and type(options) == "table" and #options == 0) then
		add_default = true
	end
	if add_default then
		local tbl = {
			text = "OK",
			is_cancel_button = true,
		}
		table.insert( options, tbl )
	end

	for _, option in ipairs( options ) do

		option.data = option.data
		option.callback = option.callback

		local button = {}
		local callback_data = {
			data = option.data,
			callback = option.callback
		}
		button.text = option.text
		button.callback_func = callback( self, self, "_callback", callback_data )
		button.cancel_button = option.is_cancel_button or false

		if option.is_focused_button then
			self.dialog_data.focus_button = #self.dialog_data.button_list + 1
		end

		table.insert( self.dialog_data.button_list, button )

	end

	if show_immediately then
		self:show()
	end

	return self

end

function QuickInputMenu:_callback( callback_data, ... )

	if callback_data.callback then
		callback_data.callback( callback_data.data, ... )
	end

	self.visible = false

end

function QuickInputMenu:Show()

	if not self.visible then
		self.visible = true
		managers.system_menu:show_input( self.dialog_data )
	end

end

function QuickInputMenu:show()
	self:Show()
end

function QuickInputMenu:Hide()

	if self.visible then
		managers.system_menu:close( self.dialog_data.id )
		self.visible = false
	end

end

function QuickInputMenu:hide()
	self:Hide()
end
