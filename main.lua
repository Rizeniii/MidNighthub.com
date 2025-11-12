local modules = {}
local cache = {}

local function registerModule(id, func)
    modules[id] = func
end

local function require(id)
    if cache[id] then return cache[id] end
    local func = modules[id]
    if not func then error("Module " .. id .. " not found!") end
    local result = func()
    cache[id] = result
    return result
end

registerModule(1, function()
    return {
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        CoreGui = game:GetService("CoreGui"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService")
    }
end)

registerModule(2, function()
    local Services = require(1)
    local Creator = {}
    Creator.Signals = {}
    
    local DefaultProps = {
        Frame = {BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0},
        TextLabel = {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamMedium, TextSize = 14},
        TextButton = {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false},
        ImageLabel = {BackgroundTransparency = 1, BorderSizePixel = 0},
        ImageButton = {BackgroundTransparency = 1, BorderSizePixel = 0},
        ScrollingFrame = {BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4}
    }
    
    function Creator.New(class, props, children)
        local instance = Instance.new(class)
        
        for prop, value in pairs(DefaultProps[class] or {}) do
            pcall(function()
                instance[prop] = value
            end)
        end
        
        for prop, value in pairs(props or {}) do
            if prop ~= "Parent" then
                pcall(function()
                    instance[prop] = value
                end)
            end
        end
        
        for _, child in pairs(children or {}) do
            child.Parent = instance
        end
        
        if props and props.Parent then
            instance.Parent = props.Parent
        end
        
        return instance
    end
    
    function Creator.AddSignal(signal, callback)
        table.insert(Creator.Signals, signal:Connect(callback))
        return Creator.Signals[#Creator.Signals]
    end
    
    function Creator.Disconnect()
        for i = #Creator.Signals, 1, -1 do
            local conn = table.remove(Creator.Signals, i)
            conn:Disconnect()
        end
    end
    
    function Creator.TweenObject(object, info, props)
        return Services.TweenService:Create(object, info, props)
    end
    
    return Creator
end)

registerModule(8, function()
    local Translator = {}
    Translator.CurrentLanguage = "English"
    
    Translator.Languages = {
        English = {
            Confirmation = "Confirmation",
            AreYouSure = "Are you sure?",
            Yes = "Yes",
            No = "No",
            ErrorOccurred = "Error Occurred",
            CopyError = "Copy Error",
            Copied = "Copied!",
            Close = "Close",
            UILoaded = "UI Loaded",
            InterfaceLoaded = "Interface loaded successfully",
            ConfigSaved = "Config Saved",
            ConfigSavedMsg = "Configuration saved successfully",
            ConfigLoaded = "Config Loaded",
            ConfigLoadedMsg = "Configuration loaded successfully",
            ConfigExported = "Config Exported",
            ConfigExportedMsg = "Configuration copied to clipboard",
            ConfigImported = "Config Imported",
            ConfigImportedMsg = "Configuration imported successfully",
            ConfigCleared = "Config Cleared",
            ConfigClearedMsg = "All configurations cleared",
            FailedToImport = "Failed to import configuration",
            ConfigNotFound = "Config not found",
            Notification = "Notification"
        },
        Portuguese = {
            Confirmation = "Confirmacao",
            AreYouSure = "Voce tem certeza?",
            Yes = "Sim",
            No = "Nao",
            ErrorOccurred = "Erro Ocorrido",
            CopyError = "Copiar Erro",
            Copied = "Copiado!",
            Close = "Fechar",
            UILoaded = "UI Carregada",
            InterfaceLoaded = "Interface carregada com sucesso",
            ConfigSaved = "Config Salva",
            ConfigSavedMsg = "Configuracao salva com sucesso",
            ConfigLoaded = "Config Carregada",
            ConfigLoadedMsg = "Configuracao carregada com sucesso",
            ConfigExported = "Config Exportada",
            ConfigExportedMsg = "Configuracao copiada para area de transferencia",
            ConfigImported = "Config Importada",
            ConfigImportedMsg = "Configuracao importada com sucesso",
            ConfigCleared = "Config Limpa",
            ConfigClearedMsg = "Todas as configuracoes foram limpas",
            FailedToImport = "Falha ao importar configuracao",
            ConfigNotFound = "Config nao encontrada",
            Notification = "Notificacao"
        },
        Spanish = {
            Confirmation = "Confirmacion",
            AreYouSure = "Estas seguro?",
            Yes = "Si",
            No = "No",
            ErrorOccurred = "Error Ocurrido",
            CopyError = "Copiar Error",
            Copied = "Copiado!",
            Close = "Cerrar",
            UILoaded = "UI Cargada",
            InterfaceLoaded = "Interfaz cargada con exito",
            ConfigSaved = "Config Guardada",
            ConfigSavedMsg = "Configuracion guardada con exito",
            ConfigLoaded = "Config Cargada",
            ConfigLoadedMsg = "Configuracion cargada con exito",
            ConfigExported = "Config Exportada",
            ConfigExportedMsg = "Configuracion copiada al portapapeles",
            ConfigImported = "Config Importada",
            ConfigImportedMsg = "Configuracion importada con exito",
            ConfigCleared = "Config Limpiada",
            ConfigClearedMsg = "Todas las configuraciones fueron limpiadas",
            FailedToImport = "Error al importar configuracion",
            ConfigNotFound = "Config no encontrada",
            Notification = "Notificacion"
        }
    }
    
    Translator.ActiveLanguage = Translator.Languages.English
    Translator.LanguageCallbacks = {}
    
    function Translator:SetLanguage(languageName)
        if self.Languages[languageName] then
            self.CurrentLanguage = languageName
            self.ActiveLanguage = self.Languages[languageName]
            
            for _, callback in pairs(self.LanguageCallbacks) do
                pcall(callback, self.ActiveLanguage)
            end
        end
    end
    
    function Translator:OnLanguageChange(callback)
        table.insert(self.LanguageCallbacks, callback)
    end
    
    function Translator:GetText(key)
        return self.ActiveLanguage[key] or key
    end
    
    function Translator:GetLanguages()
        local langs = {}
        for lang, _ in pairs(self.Languages) do
            table.insert(langs, lang)
        end
        table.sort(langs)
        return langs
    end
    
    return Translator
end)

registerModule(3, function()
    local ThemeManager = {}
    ThemeManager.CurrentTheme = "Red"
    
    ThemeManager.Themes = {
        Red = {
            Accent = Color3.fromRGB(255, 0, 0),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Purple = {
            Accent = Color3.fromRGB(138, 43, 226),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Green = {
            Accent = Color3.fromRGB(0, 255, 0),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Yellow = {
            Accent = Color3.fromRGB(255, 255, 0),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Blue = {
            Accent = Color3.fromRGB(0, 150, 255),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Cyan = {
            Accent = Color3.fromRGB(0, 255, 255),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Orange = {
            Accent = Color3.fromRGB(255, 140, 0),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        },
        Pink = {
            Accent = Color3.fromRGB(255, 105, 180),
            Background = Color3.fromRGB(0, 0, 0),
            Surface = Color3.fromRGB(15, 15, 15),
            Border = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 180, 180),
            Hover = Color3.fromRGB(25, 25, 25)
        }
    }
    
    ThemeManager.ActiveTheme = ThemeManager.Themes.Red
    ThemeManager.ThemeCallbacks = {}
    
    function ThemeManager:SetTheme(themeName)
        if self.Themes[themeName] then
            self.CurrentTheme = themeName
            self.ActiveTheme = self.Themes[themeName]
            
            for _, callback in pairs(self.ThemeCallbacks) do
                pcall(callback, self.ActiveTheme)
            end
        end
    end
    
    function ThemeManager:OnThemeChange(callback)
        table.insert(self.ThemeCallbacks, callback)
    end
    
    function ThemeManager:GetTheme()
        return self.ActiveTheme
    end
    
    return ThemeManager
end)

registerModule(6, function()
    local Icons = {
        home = "rbxassetid://10723434711",
        settings = "rbxassetid://10734950309",
        user = "rbxassetid://10723407389",
        combat = "rbxassetid://10723424505",
        gamepad = "rbxassetid://10723396308",
        visual = "rbxassetid://10723374235",
        misc = "rbxassetid://10723350698",
        info = "rbxassetid://10723345866",
        search = "rbxassetid://10723341447",
        star = "rbxassetid://10723397719",
        check = "rbxassetid://10709791437",
        close = "rbxassetid://10747384394",
        chevrondown = "rbxassetid://10709818534",
        chevronup = "rbxassetid://10709819149"
    }
    
    function Icons.GetIcon(keyword)
        return Icons[keyword] or "rbxassetid://10723434711"
    end
    
    return Icons
end)

registerModule(7, function()
    local Services = require(1)
    local Creator = require(2)
    local ThemeManager = require(3)
    
    local ConfigManager = {}
    ConfigManager.CurrentConfig = {}
    
    function ConfigManager:Save(name, data)
        self.CurrentConfig[name] = data
        return true
    end
    
    function ConfigManager:Load(name)
        return self.CurrentConfig[name]
    end
    
    function ConfigManager:GetAll()
        return self.CurrentConfig
    end
    
    function ConfigManager:Delete(name)
        self.CurrentConfig[name] = nil
        return true
    end
    
    function ConfigManager:Clear()
        self.CurrentConfig = {}
        return true
    end
    
    function ConfigManager:Export()
        return Services.HttpService:JSONEncode(self.CurrentConfig)
    end
    
    function ConfigManager:Import(jsonData)
        local success, result = pcall(function()
            return Services.HttpService:JSONDecode(jsonData)
        end)
        
        if success then
            self.CurrentConfig = result
            return true
        end
        
        return false
    end
    
    return ConfigManager
end)

registerModule(4, function()
    local Services = require(1)
    local Creator = require(2)
    local ThemeManager = require(3)
    local Icons = require(6)
    local ConfigManager = require(7)
    local Translator = require(8)
    
    local Elements = {}
    
    function Elements.CreateConfirmDialog(parent, config)
        local Theme = ThemeManager:GetTheme()
        
        local Dialog = Creator.New("Frame", {
            Size = UDim2.new(0, 350, 0, 180),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Background,
            ZIndex = 101,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            Creator.New("UIStroke", {Color = Theme.Accent, Thickness = 1})
        })
        
        local TitleLabel = Creator.New("TextLabel", {
            Text = config.Title or Translator:GetText("Confirmation"),
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 15),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = Dialog
        })
        
        local MessageLabel = Creator.New("TextLabel", {
            Text = config.Message or Translator:GetText("AreYouSure"),
            Size = UDim2.new(1, -40, 0, 60),
            Position = UDim2.new(0, 20, 0, 55),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            TextColor3 = Theme.SubText,
            ZIndex = 102,
            Parent = Dialog
        })
        
        local ButtonContainer = Creator.New("Frame", {
            Size = UDim2.new(1, -40, 0, 35),
            Position = UDim2.new(0, 20, 1, -50),
            BackgroundTransparency = 1,
            ZIndex = 102,
            Parent = Dialog
        })
        
        local YesButton = Creator.New("TextButton", {
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.fromScale(0, 0),
            BackgroundColor3 = Theme.Accent,
            Text = config.ConfirmText or Translator:GetText("Yes"),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            ZIndex = 103,
            Parent = ButtonContainer
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
        })
        
        local NoButton = Creator.New("TextButton", {
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.fromScale(0.52, 0),
            BackgroundColor3 = Theme.Surface,
            Text = config.CancelText or Translator:GetText("No"),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            ZIndex = 103,
            Parent = ButtonContainer
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1})
        })
        
        YesButton.MouseButton1Click:Connect(function()
            Dialog:Destroy()
            if config.OnConfirm then
                task.spawn(config.OnConfirm)
            end
        end)
        
        NoButton.MouseButton1Click:Connect(function()
            Dialog:Destroy()
            if config.OnCancel then
                task.spawn(config.OnCancel)
            end
        end)
        
        return Dialog
    end
    
    function Elements.CreateErrorDialog(parent, errorMessage, onCopy)
        local Theme = ThemeManager:GetTheme()
        
        local Dialog = Creator.New("Frame", {
            Size = UDim2.new(0, 400, 0, 220),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Background,
            ZIndex = 101,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            Creator.New("UIStroke", {Color = Theme.Accent, Thickness = 1})
        })
        
        local TitleLabel = Creator.New("TextLabel", {
            Text = Translator:GetText("ErrorOccurred"),
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 15),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.Accent,
            ZIndex = 102,
            Parent = Dialog
        })
        
        local ErrorBox = Creator.New("Frame", {
            Size = UDim2.new(1, -40, 0, 90),
            Position = UDim2.new(0, 20, 0, 55),
            BackgroundColor3 = Theme.Surface,
            ZIndex = 102,
            Parent = Dialog
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
        })
        
        local ErrorLabel = Creator.New("TextLabel", {
            Text = errorMessage,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            Font = Enum.Font.Code,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            TextColor3 = Theme.Text,
            ZIndex = 103,
            Parent = ErrorBox
        })
        
        local ButtonContainer = Creator.New("Frame", {
            Size = UDim2.new(1, -40, 0, 35),
            Position = UDim2.new(0, 20, 1, -50),
            BackgroundTransparency = 1,
            ZIndex = 102,
            Parent = Dialog
        })
        
        local CopyButton = Creator.New("TextButton", {
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.fromScale(0, 0),
            BackgroundColor3 = Theme.Accent,
            Text = Translator:GetText("CopyError"),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            ZIndex = 103,
            Parent = ButtonContainer
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
        })
        
        local CloseButton = Creator.New("TextButton", {
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.fromScale(0.52, 0),
            BackgroundColor3 = Theme.Surface,
            Text = Translator:GetText("Close"),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            ZIndex = 103,
            Parent = ButtonContainer
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1})
        })
        
        CopyButton.MouseButton1Click:Connect(function()
            if onCopy then
                task.spawn(onCopy, errorMessage)
            end
            pcall(function()
                setclipboard(errorMessage)
            end)
            CopyButton.Text = Translator:GetText("Copied")
            task.wait(1)
            if CopyButton and CopyButton.Parent then
                CopyButton.Text = Translator:GetText("CopyError")
            end
        end)
        
        CloseButton.MouseButton1Click:Connect(function()
            Dialog:Destroy()
        end)
        
        return Dialog
    end
    
    function Elements.CreateToggle(parent, config)
        local Theme = ThemeManager:GetTheme()
        local toggle = {Value = config.Default or false, Enabled = true}
        
        local Container = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.3,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5})
        })
        
        local IconImg
        if config.Icon and config.IconPosition == "before" then
            IconImg = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(0, 15, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        local labelOffset = (config.Icon and config.IconPosition == "before") and 45 or 18
        
        local Label = Creator.New("TextLabel", {
            Text = config.Title,
            Position = UDim2.new(0, labelOffset, 0, 0),
            Size = UDim2.new(1, -100 - (labelOffset - 18), 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })
        
        local Button = Creator.New("TextButton", {
            Size = UDim2.new(0, 50, 0, 26),
            Position = UDim2.new(1, -65, 0.5, -13),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Text = "",
            Parent = Container
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        local IconImg2
        if config.Icon and config.IconPosition == "after" then
            Button.Position = UDim2.new(1, -90, 0.5, -13)
            IconImg2 = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -60, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        local Indicator = Creator.New("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 3, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(120, 120, 120),
            Parent = Button
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        function toggle:SetValue(value, silent)
            if not toggle.Enabled then return end
            
            toggle.Value = value
            local pos = value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            local currentTheme = ThemeManager:GetTheme()
            local color = value and currentTheme.Accent or Color3.fromRGB(120, 120, 120)
            local bgColor = value and Color3.fromRGB(50, 20, 20) or Color3.fromRGB(35, 35, 35)
            
            Creator.TweenObject(Indicator, TweenInfo.new(0.3), {Position = pos, BackgroundColor3 = color}):Play()
            Creator.TweenObject(Button, TweenInfo.new(0.3), {BackgroundColor3 = bgColor}):Play()
            
            if config.SaveConfig then
                ConfigManager:Save(config.Title, value)
            end
            
            if not silent then
                pcall(function()
                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end)
            end
        end
        
        function toggle:SetEnabled(enabled)
            toggle.Enabled = enabled
            Button.Active = enabled
            Container.BackgroundTransparency = enabled and 0.3 or 0.6
        end
        
        Creator.AddSignal(Button.MouseButton1Click, function()
            if not toggle.Enabled then return end
            
            if config.ConfirmDialog then
                local dialog = Elements.CreateConfirmDialog(parent.Parent.Parent.Parent, {
                    Title = config.ConfirmDialog.Title or Translator:GetText("Confirmation"),
                    Message = config.ConfirmDialog.Message or Translator:GetText("AreYouSure"),
                    ConfirmText = config.ConfirmDialog.ConfirmText or Translator:GetText("Yes"),
                    CancelText = config.ConfirmDialog.CancelText or Translator:GetText("No"),
                    OnConfirm = function()
                        toggle:SetValue(not toggle.Value)
                    end
                })
            else
                toggle:SetValue(not toggle.Value)
            end
        end)
        
        ThemeManager:OnThemeChange(function(newTheme)
            local color = toggle.Value and newTheme.Accent or Color3.fromRGB(120, 120, 120)
            Indicator.BackgroundColor3 = color
            if IconImg then
                IconImg.ImageColor3 = newTheme.Text
            end
            if IconImg2 then
                IconImg2.ImageColor3 = newTheme.Text
            end
        end)
        
        if config.SaveConfig then
            local saved = ConfigManager:Load(config.Title)
            if saved ~= nil then
                toggle:SetValue(saved, true)
            else
                toggle:SetValue(toggle.Value, true)
            end
        else
            toggle:SetValue(toggle.Value, true)
        end
        
        return toggle
    end
    
    function Elements.CreateButton(parent, config)
        local Theme = ThemeManager:GetTheme()
        local button = {Enabled = true}
        
        local Container = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.3,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5})
        })
        
        local Button = Creator.New("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            Parent = Container
        })
        
        local IconImg
        if config.Icon and config.IconPosition == "before" then
            IconImg = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(0, 15, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        local labelOffset = (config.Icon and config.IconPosition == "before") and 45 or 18
        
        local Label = Creator.New("TextLabel", {
            Text = config.Title,
            Position = UDim2.new(0, labelOffset, 0, 0),
            Size = UDim2.new(1, -36 - (labelOffset - 18), 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })
        
        local Icon = Creator.New("ImageLabel", {
            Image = Icons.GetIcon("check"),
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            ImageColor3 = Theme.Text,
            Parent = Container
        })
        
        local IconImg2
        if config.Icon and config.IconPosition == "after" then
            Icon.Position = UDim2.new(1, -50, 0.5, -8)
            IconImg2 = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -26, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        function button:SetEnabled(enabled)
            button.Enabled = enabled
            Button.Active = enabled
            Container.BackgroundTransparency = enabled and 0.3 or 0.6
        end
        
        Creator.AddSignal(Button.MouseEnter, function()
            if not button.Enabled then return end
            Creator.TweenObject(Container, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
        end)
        
        Creator.AddSignal(Button.MouseLeave, function()
            if not button.Enabled then return end
            Creator.TweenObject(Container, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        end)
        
        Creator.AddSignal(Button.MouseButton1Click, function()
            if not button.Enabled then return end
            
            pcall(function()
                if config.Callback then
                    task.spawn(config.Callback)
                end
            end)
        end)
        
        ThemeManager:OnThemeChange(function(newTheme)
            Icon.ImageColor3 = newTheme.Text
            if IconImg then
                IconImg.ImageColor3 = newTheme.Text
            end
            if IconImg2 then
                IconImg2.ImageColor3 = newTheme.Text
            end
        end)
        
        button.Container = Container
        button.Button = Button
        
        return button
    end
    
    function Elements.CreateSlider(parent, config)
        local Theme = ThemeManager:GetTheme()
        local slider = {Value = config.Default or config.Min, Enabled = true}
        
        local Container = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.3,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5})
        })
        
        local Label = Creator.New("TextLabel", {
            Text = config.Title,
            Position = UDim2.new(0, 18, 0, 10),
            Size = UDim2.new(1, -36, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })
        
        local ValueLabel = Creator.New("TextLabel", {
            Text = tostring(slider.Value),
            Position = UDim2.new(1, -70, 0, 10),
            Size = UDim2.new(0, 50, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Right,
            TextColor3 = Theme.SubText,
            Parent = Container
        })
        
        local Rail = Creator.New("Frame", {
            Size = UDim2.new(1, -36, 0, 4),
            Position = UDim2.new(0, 18, 1, -20),
            BackgroundColor3 = Theme.Border,
            BackgroundTransparency = 0.4,
            Parent = Container
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        local Fill = Creator.New("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            Parent = Rail
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        local Thumb = Creator.New("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(0, -7, 0.5, -7),
            BackgroundColor3 = Theme.Accent,
            Parent = Rail
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        
        local ThumbButton = Creator.New("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            Parent = Thumb
        })
        
        local RailButton = Creator.New("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            Parent = Rail
        })
        
        local dragging = false
        
        function slider:SetValue(value, silent)
            if not slider.Enabled then return end
            
            value = math.clamp(value, config.Min, config.Max)
            if config.Rounding then
                value = math.floor(value / config.Rounding + 0.5) * config.Rounding
            end
            slider.Value = value
            
            local percent = (value - config.Min) / (config.Max - config.Min)
            Fill.Size = UDim2.fromScale(percent, 1)
            Thumb.Position = UDim2.new(percent, -7, 0.5, -7)
            ValueLabel.Text = tostring(value)
            
            if config.SaveConfig then
                ConfigManager:Save(config.Title, value)
            end
            
            if not silent then
                pcall(function()
                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end)
            end
        end
        
        function slider:SetEnabled(enabled)
            slider.Enabled = enabled
            ThumbButton.Active = enabled
            RailButton.Active = enabled
            Container.BackgroundTransparency = enabled and 0.3 or 0.6
        end
        
        local function UpdateSlider(input)
            if not slider.Enabled then return end
            
            local percent = math.clamp((input.Position.X - Rail.AbsolutePosition.X) / Rail.AbsoluteSize.X, 0, 1)
            local value = config.Min + ((config.Max - config.Min) * percent)
            slider:SetValue(value)
        end
        
        Creator.AddSignal(ThumbButton.MouseButton1Down, function()
            if not slider.Enabled then return end
            dragging = true
        end)
        
        Creator.AddSignal(RailButton.MouseButton1Down, function(x, y)
            if not slider.Enabled then return end
            dragging = true
            UpdateSlider({Position = Vector2.new(x, y)})
        end)
        
        Creator.AddSignal(ThumbButton.InputBegan, function(input)
            if not slider.Enabled then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        Creator.AddSignal(RailButton.InputBegan, function(input)
            if not slider.Enabled then return end
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        Creator.AddSignal(Services.UserInputService.InputChanged, function(input)
            if dragging and slider.Enabled then
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(input)
                end
            end
        end)
        
        Creator.AddSignal(Services.UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        ThemeManager:OnThemeChange(function(newTheme)
            Fill.BackgroundColor3 = newTheme.Accent
            Thumb.BackgroundColor3 = newTheme.Accent
        end)
        
        if config.SaveConfig then
            local saved = ConfigManager:Load(config.Title)
            if saved ~= nil then
                slider:SetValue(saved, true)
            else
                slider:SetValue(slider.Value, true)
            end
        else
            slider:SetValue(slider.Value, true)
        end
        
        return slider
    end
    
    function Elements.CreateDropdown(parent, config)
        local Theme = ThemeManager:GetTheme()
        local dropdown = {Value = config.Default or (config.Options[1] or ""), Enabled = true, IsOpen = false}
        
        local Container = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.3,
            Parent = parent
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5})
        })
        
        local IconImg
        if config.Icon and config.IconPosition == "before" then
            IconImg = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(0, 15, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        local labelOffset = (config.Icon and config.IconPosition == "before") and 45 or 18
        
        local Label = Creator.New("TextLabel", {
            Text = config.Title,
            Position = UDim2.new(0, labelOffset, 0, 0),
            Size = UDim2.new(1, -100 - (labelOffset - 18), 0, 25),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })
        
        local ValueLabel = Creator.New("TextLabel", {
            Text = dropdown.Value,
            Position = UDim2.new(0, labelOffset, 0, 25),
            Size = UDim2.new(1, -100 - (labelOffset - 18), 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            Parent = Container
        })
        
        local ChevronIcon = Creator.New("ImageLabel", {
            Image = Icons.GetIcon("chevrondown"),
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(1, -26, 0.5, -8),
            ImageColor3 = Theme.Text,
            Parent = Container
        })
        
        local IconImg2
        if config.Icon and config.IconPosition == "after" then
            ChevronIcon.Position = UDim2.new(1, -50, 0.5, -8)
            IconImg2 = Creator.New("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -26, 0.5, -10),
                ImageColor3 = Theme.Text,
                Parent = Container
            })
        end
        
        local Button = Creator.New("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 2,
            Parent = Container
        })
        
        local OptionsFrame = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = Theme.Surface,
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 300,
            Parent = Container
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Creator.New("UIStroke", {Color = Theme.Border, Thickness = 1})
        })
        
        local OptionsScroll = Creator.New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ZIndex = 301,
            Parent = OptionsFrame
        }, {
            Creator.New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
            Creator.New("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
        })
        
        local OptionsLayout = OptionsScroll:FindFirstChildOfClass("UIListLayout")
        
        function dropdown:SetValue(value, silent)
            if not dropdown.Enabled then return end
            
            dropdown.Value = value
            ValueLabel.Text = value
            
            if config.SaveConfig then
                ConfigManager:Save(config.Title, value)
            end
            
            if not silent then
                pcall(function()
                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end)
            end
        end
        
        function dropdown:SetEnabled(enabled)
            dropdown.Enabled = enabled
            Button.Active = enabled
            Container.BackgroundTransparency = enabled and 0.3 or 0.6
        end
        
        function dropdown:Refresh(newOptions)
            for _, child in pairs(OptionsScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            config.Options = newOptions or config.Options
            
            for _, option in ipairs(config.Options) do
                local OptionButton = Creator.New("TextButton", {
                    Size = UDim2.new(1, -10, 0, 35),
                    BackgroundColor3 = Theme.Hover,
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 302,
                    Parent = OptionsScroll
                }, {
                    Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Creator.New("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                })
                
                Creator.AddSignal(OptionButton.MouseEnter, function()
                    Creator.TweenObject(OptionButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end)
                
                Creator.AddSignal(OptionButton.MouseLeave, function()
                    Creator.TweenObject(OptionButton, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end)
                
                Creator.AddSignal(OptionButton.MouseButton1Click, function()
                    if not dropdown.Enabled then return end
                    
                    dropdown:SetValue(option)
                    dropdown:Close()
                end)
            end
            
            task.wait()
            OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 10)
        end
        
        function dropdown:Open()
            if not dropdown.Enabled or dropdown.IsOpen then return end
            
            dropdown.IsOpen = true
            local optionCount = #config.Options
            local totalHeight = math.min(optionCount * 37 + 10, 200)
            
            OptionsFrame.Visible = true
            
            Creator.TweenObject(OptionsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, totalHeight)}):Play()
            Creator.TweenObject(ChevronIcon, TweenInfo.new(0.3), {Rotation = 180}):Play()
        end
        
        function dropdown:Close()
            if not dropdown.IsOpen then return end
            
            dropdown.IsOpen = false
            Creator.TweenObject(OptionsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            Creator.TweenObject(ChevronIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
            
            task.delay(0.3, function()
                if not dropdown.IsOpen then
                    OptionsFrame.Visible = false
                end
            end)
        end
        
        function dropdown:Toggle()
            if dropdown.IsOpen then
                dropdown:Close()
            else
                dropdown:Open()
            end
        end
        
        Creator.AddSignal(Button.MouseButton1Click, function()
            if not dropdown.Enabled then return end
            dropdown:Toggle()
        end)
        
        Creator.AddSignal(OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 10)
        end)
        
        ThemeManager:OnThemeChange(function(newTheme)
            ChevronIcon.ImageColor3 = newTheme.Text
            OptionsScroll.ScrollBarImageColor3 = newTheme.Accent
            OptionsFrame.BackgroundColor3 = newTheme.Surface
            Container.BackgroundColor3 = newTheme.Surface
            Label.TextColor3 = newTheme.Text
            ValueLabel.TextColor3 = newTheme.SubText
            if IconImg then
                IconImg.ImageColor3 = newTheme.Text
            end
            if IconImg2 then
                IconImg2.ImageColor3 = newTheme.Text
            end
            
            for _, child in pairs(OptionsScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = newTheme.Text
                end
            end
        end)
        
        dropdown:Refresh(config.Options)
        
        if config.SaveConfig then
            local saved = ConfigManager:Load(config.Title)
            if saved ~= nil then
                dropdown:SetValue(saved, true)
            else
                dropdown:SetValue(dropdown.Value, true)
            end
        else
            dropdown:SetValue(dropdown.Value, true)
        end
        
        dropdown.Container = Container
        
        return dropdown
    end
    
    return Elements
end)

registerModule(5, function()
    local Services = require(1)
    local Creator = require(2)
    local ThemeManager = require(3)
    local Elements = require(4)
    local Icons = require(6)
    local ConfigManager = require(7)
    local Translator = require(8)
    
    local Library = {}
    Library.Version = "2.2.0"
    
    function Library:CreateWindow(config)
        local Window = {}
        Window.Tabs = {}
        Window.NotificationQueue = {}
        Window.ThemeElements = {}
        Window.ActiveDropdowns = {}
        
        local ScreenGui = Creator.New("ScreenGui", {
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false,
            Parent = Services.CoreGui
        })
        
        local Theme = ThemeManager:GetTheme()
        
        local MainFrame = Creator.New("Frame", {
            Size = config.Size or UDim2.new(0, 600, 0, 500),
            Position = UDim2.new(0.5, -300, 0.5, -250),
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.05,
            Parent = ScreenGui
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 16)}),
            Creator.New("UIStroke", {Color = Theme.Accent, Thickness = 1, Transparency = 0.8})
        })
        
        table.insert(Window.ThemeElements, {Object = MainFrame:FindFirstChildOfClass("UIStroke"), Property = "Color", ColorKey = "Accent"})
        
        local dragging = false
        local dragInput, dragStart, startPos
        
        local TopBar = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
        
        local DragArea = Creator.New("TextButton", {
            Size = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = TopBar
        })
        
        Creator.AddSignal(DragArea.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        Creator.AddSignal(DragArea.InputChanged, function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        Creator.AddSignal(Services.UserInputService.InputChanged, function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        local resizing = false
        local resizeStart, resizeStartSize
        local minSize = UDim2.new(0, 400, 0, 350)
        local maxSize = UDim2.new(0, 1000, 0, 800)
        
        local ResizeHandle = Creator.New("TextButton", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.7,
            Text = "",
            ZIndex = 10,
            Parent = MainFrame
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)})
        })
        
        table.insert(Window.ThemeElements, {Object = ResizeHandle, Property = "BackgroundColor3", ColorKey = "Accent"})
        
        Creator.AddSignal(ResizeHandle.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                resizeStartSize = MainFrame.Size
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        resizing = false
                    end
                end)
            end
        end)
        
        Creator.AddSignal(Services.UserInputService.InputChanged, function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local newWidth = math.clamp(resizeStartSize.X.Offset + delta.X, minSize.X.Offset, maxSize.X.Offset)
                local newHeight = math.clamp(resizeStartSize.Y.Offset + delta.Y, minSize.Y.Offset, maxSize.Y.Offset)
                MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                
                task.spawn(function()
                    task.wait()
                    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
                end)
            end
        end)
        
        local logoImage = config.Logo or "rbxassetid://117809658545028"
        
        local Logo = Creator.New("ImageLabel", {
            Position = UDim2.new(0, 20, 0.5, -18),
            Size = UDim2.fromOffset(36, 36),
            Image = logoImage,
            ImageColor3 = Theme.Accent,
            Parent = TopBar
        })
        
        table.insert(Window.ThemeElements, {Object = Logo, Property = "ImageColor3", ColorKey = "Accent"})
        
        local Title = Creator.New("TextLabel", {
            Text = config.Title or "MidNight Hub",
            Position = UDim2.new(0, 64, 0, 0),
            Size = UDim2.new(0, 250, 1, 0),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TopBar
        })
        
        local CloseButton = Creator.New("TextButton", {
            Text = "X",
            Size = UDim2.fromOffset(32, 32),
            Position = UDim2.new(1, -46, 0, 14),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0.3,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = TopBar
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)})
        })
        
        local TabContainer = Creator.New("ScrollingFrame", {
            Size = UDim2.new(0, 180, 1, -85),
            Position = UDim2.new(0, 15, 0, 70),
            BackgroundTransparency = 1,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = MainFrame
        }, {
            Creator.New("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
        })
        
        table.insert(Window.ThemeElements, {Object = TabContainer, Property = "ScrollBarImageColor3", ColorKey = "Accent"})
        
        local TabLayout = TabContainer:FindFirstChildOfClass("UIListLayout")
        Creator.AddSignal(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local ContentContainer = Creator.New("Frame", {
            Size = UDim2.new(1, -220, 1, -85),
            Position = UDim2.new(0, 205, 0, 70),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
        
        local NotificationContainer = Creator.New("Frame", {
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -330, 0, 10),
            BackgroundTransparency = 1,
            Parent = ScreenGui
        }, {
            Creator.New("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            })
        })
        
        local floatingConfig = config.FloatingButton or {}
        local showFloating = floatingConfig.Enabled ~= false
        
        local FloatingButton
        if showFloating then
            FloatingButton = Creator.New("ImageButton", {
                Size = UDim2.fromOffset(70, 70),
                Position = UDim2.new(0, 15, 0.5, -35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BackgroundTransparency = 0.2,
                Image = floatingConfig.Image or logoImage,
                ImageColor3 = Theme.Accent,
                Visible = true,
                Parent = ScreenGui
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 16)}),
                Creator.New("UIStroke", {Color = Theme.Accent, Thickness = 2, Transparency = 0.5})
            })
            
            table.insert(Window.ThemeElements, {Object = FloatingButton, Property = "ImageColor3", ColorKey = "Accent"})
            table.insert(Window.ThemeElements, {Object = FloatingButton:FindFirstChildOfClass("UIStroke"), Property = "Color", ColorKey = "Accent"})
            
            local floatDragging = false
            local floatDragStart, floatStartPos
            
            Creator.AddSignal(FloatingButton.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    floatDragging = true
                    floatDragStart = input.Position
                    floatStartPos = FloatingButton.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            floatDragging = false
                        end
                    end)
                end
            end)
            
            Creator.AddSignal(Services.UserInputService.InputChanged, function(input)
                if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - floatDragStart
                    FloatingButton.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
                end
            end)
        end
        
        local isOpen = true
        local toggleKey = config.ToggleKey or Enum.KeyCode.LeftControl
        
        local function CloseAllDropdowns()
            for _, dropdown in pairs(Window.ActiveDropdowns) do
                if dropdown and dropdown.Close then
                    dropdown:Close()
                end
            end
        end
        
        Creator.AddSignal(Services.UserInputService.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                task.spawn(CloseAllDropdowns)
            end
        end)
        
        local function ToggleUI()
            isOpen = not isOpen
            if isOpen then
                MainFrame.Visible = true
                Creator.TweenObject(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = config.Size or UDim2.new(0, 600, 0, 500)}):Play()
                task.wait(0.4)
                task.spawn(function()
                    ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
                end)
            else
                CloseAllDropdowns()
                Creator.TweenObject(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                task.wait(0.3)
                MainFrame.Visible = false
            end
        end
        
        function Window:Notify(notifyConfig)
            local currentTheme = ThemeManager:GetTheme()
            
            local NotifyFrame = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 80),
                BackgroundColor3 = currentTheme.Surface,
                BackgroundTransparency = 1,
                Parent = NotificationContainer
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 12)}),
                Creator.New("UIStroke", {Color = currentTheme.Border, Thickness = 1, Transparency = 0.5})
            })
            
            local IconImage = Creator.New("ImageLabel", {
                Position = UDim2.new(0, 15, 0.5, -18),
                Size = UDim2.fromOffset(36, 36),
                Image = notifyConfig.Icon or Icons.GetIcon("info"),
                ImageColor3 = currentTheme.Accent,
                Parent = NotifyFrame
            })
            
            local TitleLabel = Creator.New("TextLabel", {
                Text = notifyConfig.Title or Translator:GetText("Notification"),
                Position = UDim2.new(0, 60, 0, 12),
                Size = UDim2.new(1, -70, 0, 18),
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = NotifyFrame
            })
            
            local ContentLabel = Creator.New("TextLabel", {
                Text = notifyConfig.Content or "",
                Position = UDim2.new(0, 60, 0, 35),
                Size = UDim2.new(1, -70, 0, 35),
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                TextColor3 = currentTheme.SubText,
                Parent = NotifyFrame
            })
            
            Creator.TweenObject(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0.1}):Play()
            
            task.delay(notifyConfig.Duration or 3, function()
                if NotifyFrame and NotifyFrame.Parent then
                    Creator.TweenObject(NotifyFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    task.wait(0.3)
                    if NotifyFrame and NotifyFrame.Parent then
                        NotifyFrame:Destroy()
                    end
                end
            end)
        end
        
        function Window:ShowError(errorMsg)
            Elements.CreateErrorDialog(ScreenGui, errorMsg, function(msg)
                pcall(function()
                    setclipboard(msg)
                end)
            end)
        end
        
        Creator.AddSignal(CloseButton.MouseButton1Click, function()
            CloseAllDropdowns()
            Creator.TweenObject(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.3)
            ScreenGui:Destroy()
        end)
        
        if FloatingButton then
            Creator.AddSignal(FloatingButton.MouseButton1Click, ToggleUI)
        end
        
        Creator.AddSignal(Services.UserInputService.InputBegan, function(input, processed)
            if not processed and input.KeyCode == toggleKey then
                ToggleUI()
            end
        end)
        
        task.delay(0.1, function()
            Window:Notify({
                Title = Translator:GetText("UILoaded"),
                Content = Translator:GetText("InterfaceLoaded"),
                Icon = Icons.GetIcon("info"),
                Duration = 3
            })
        end)
        
        function Window:AddTab(tabConfig)
            local Tab = {}
            local tabName, tabIcon, tabDescription
            
            if type(tabConfig) == "string" then
                tabName = tabConfig
                tabIcon = Icons.GetIcon("home")
                tabDescription = nil
            else
                tabName = tabConfig.Name
                tabIcon = tabConfig.Icon or Icons.GetIcon("home")
                tabDescription = tabConfig.Description
            end
            
            local currentTheme = ThemeManager:GetTheme()
            
            local TabButton = Creator.New("TextButton", {
                Size = UDim2.new(1, 0, 0, tabDescription and 65 or 48),
                BackgroundColor3 = currentTheme.Surface,
                BackgroundTransparency = 1,
                Text = "",
                Parent = TabContainer
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 10)})
            })
            
            local TabIcon = Creator.New("ImageLabel", {
                Position = UDim2.new(0, 15, tabDescription and 0, 15 or 0.5, -12),
                Size = UDim2.fromOffset(24, 24),
                Image = tabIcon,
                ImageColor3 = Color3.fromRGB(120, 120, 120),
                Parent = TabButton
            })
            
            local TabLabel = Creator.New("TextLabel", {
                Text = tabName,
                Position = UDim2.new(0, 47, 0, tabDescription and 10 or 0),
                Size = UDim2.new(1, -55, 0, tabDescription and 20 or 48),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = tabDescription and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                Parent = TabButton
            })
            
            local DescLabel
            if tabDescription then
                DescLabel = Creator.New("TextLabel", {
                    Text = tabDescription,
                    Position = UDim2.new(0, 47, 0, 32),
                    Size = UDim2.new(1, -55, 0, 25),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextColor3 = Color3.fromRGB(120, 120, 120),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextWrapped = true,
                    Parent = TabButton
                })
            end
            
            local Content = Creator.New("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                ScrollBarImageColor3 = currentTheme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Visible = false,
                Parent = ContentContainer
            }, {
                Creator.New("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}),
                Creator.New("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})
            })
            
            table.insert(Window.ThemeElements, {Object = Content, Property = "ScrollBarImageColor3", ColorKey = "Accent"})
            
            local Layout = Content:FindFirstChildOfClass("UIListLayout")
            Creator.AddSignal(Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
            end)
            
            Creator.AddSignal(TabButton.MouseButton1Click, function()
                CloseAllDropdowns()
                
                for _, tab in pairs(Window.Tabs) do
                    tab.Content.Visible = false
                    Creator.TweenObject(tab.Button, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                    Creator.TweenObject(tab.Icon, TweenInfo.new(0.25), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                    Creator.TweenObject(tab.Label, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    if tab.DescLabel then
                        Creator.TweenObject(tab.DescLabel, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
                    end
                end
                
                local activeTheme = ThemeManager:GetTheme()
                Content.Visible = true
                Creator.TweenObject(TabButton, TweenInfo.new(0.25), {BackgroundTransparency = 0.7, BackgroundColor3 = activeTheme.Surface}):Play()
                Creator.TweenObject(TabIcon, TweenInfo.new(0.25), {ImageColor3 = activeTheme.Accent}):Play()
                Creator.TweenObject(TabLabel, TweenInfo.new(0.25), {TextColor3 = activeTheme.Text}):Play()
                if DescLabel then
                    Creator.TweenObject(DescLabel, TweenInfo.new(0.25), {TextColor3 = activeTheme.SubText}):Play()
                end
            end)
            
            function Tab:AddToggle(config)
                local success, result = pcall(function()
                    return Elements.CreateToggle(Content, config)
                end)
                
                if not success then
                    Window:ShowError(tostring(result))
                    return nil
                end
                
                return result
            end
            
            function Tab:AddButton(config)
                local success, result = pcall(function()
                    return Elements.CreateButton(Content, config)
                end)
                
                if not success then
                    Window:ShowError(tostring(result))
                    return nil
                end
                
                return result
            end
            
            function Tab:AddSlider(config)
                local success, result = pcall(function()
                    return Elements.CreateSlider(Content, config)
                end)
                
                if not success then
                    Window:ShowError(tostring(result))
                    return nil
                end
                
                return result
            end
            
            function Tab:AddDropdown(config)
                local success, result = pcall(function()
                    local dropdown = Elements.CreateDropdown(Content, config)
                    table.insert(Window.ActiveDropdowns, dropdown)
                    return dropdown
                end)
                
                if not success then
                    Window:ShowError(tostring(result))
                    return nil
                end
                
                return result
            end
            
            table.insert(Window.Tabs, {
                Button = TabButton,
                Icon = TabIcon,
                Label = TabLabel,
                DescLabel = DescLabel,
                Content = Content,
                Tab = Tab
            })
            
            if #Window.Tabs == 1 then
                task.spawn(function()
                    task.wait(0.1)
                    TabButton.MouseButton1Click:Fire()
                end)
            end
            
            return Tab
        end
        
        function Window:SetTheme(themeName)
            ThemeManager:SetTheme(themeName)
            local newTheme = ThemeManager:GetTheme()
            
            for _, element in pairs(Window.ThemeElements) do
                if element.Object and element.Property and element.ColorKey then
                    Creator.TweenObject(element.Object, TweenInfo.new(0.3), {[element.Property] = newTheme[element.ColorKey]}):Play()
                end
            end
        end
        
        function Window:GetThemes()
            local themeList = {}
            for themeName, _ in pairs(ThemeManager.Themes) do
                table.insert(themeList, themeName)
            end
            table.sort(themeList)
            return themeList
        end
        
        function Window:GetCurrentTheme()
            return ThemeManager.CurrentTheme
        end
        
        function Window:SetLanguage(language)
            Translator:SetLanguage(language)
        end
        
        function Window:GetLanguages()
            return Translator:GetLanguages()
        end
        
        function Window:GetCurrentLanguage()
            return Translator.CurrentLanguage
        end
        
        function Window:Destroy()
            CloseAllDropdowns()
            ScreenGui:Destroy()
            Creator.Disconnect()
        end
        
        function Window:SaveConfig(name)
            local success, result = pcall(function()
                local allConfigs = ConfigManager:GetAll()
                return ConfigManager:Save(name, allConfigs)
            end)
            
            if success then
                Window:Notify({
                    Title = Translator:GetText("ConfigSaved"),
                    Content = Translator:GetText("ConfigSavedMsg"),
                    Icon = Icons.GetIcon("check"),
                    Duration = 2
                })
            else
                Window:ShowError(tostring(result))
            end
            
            return success
        end
        
        function Window:LoadConfig(name)
            local success, result = pcall(function()
                return ConfigManager:Load(name)
            end)
            
            if success and result then
                Window:Notify({
                    Title = Translator:GetText("ConfigLoaded"),
                    Content = Translator:GetText("ConfigLoadedMsg"),
                    Icon = Icons.GetIcon("check"),
                    Duration = 2
                })
                return result
            else
                Window:ShowError(tostring(result or Translator:GetText("ConfigNotFound")))
            end
            
            return nil
        end
        
        function Window:ExportConfig()
            local success, result = pcall(function()
                return ConfigManager:Export()
            end)
            
            if success then
                pcall(function()
                    setclipboard(result)
                end)
                Window:Notify({
                    Title = Translator:GetText("ConfigExported"),
                    Content = Translator:GetText("ConfigExportedMsg"),
                    Icon = Icons.GetIcon("check"),
                    Duration = 2
                })
                return result
            else
                Window:ShowError(tostring(result))
            end
            
            return nil
        end
        
        function Window:ImportConfig(jsonData)
            local success, result = pcall(function()
                return ConfigManager:Import(jsonData)
            end)
            
            if success and result then
                Window:Notify({
                    Title = Translator:GetText("ConfigImported"),
                    Content = Translator:GetText("ConfigImportedMsg"),
                    Icon = Icons.GetIcon("check"),
                    Duration = 2
                })
            else
                Window:ShowError(Translator:GetText("FailedToImport"))
            end
            
            return success
        end
        
        function Window:ClearConfig()
            local success = pcall(function()
                ConfigManager:Clear()
            end)
            
            if success then
                Window:Notify({
                    Title = Translator:GetText("ConfigCleared"),
                    Content = Translator:GetText("ConfigClearedMsg"),
                    Icon = Icons.GetIcon("info"),
                    Duration = 2
                })
            end
            
            return success
        end
        
        function Window:SetToggleKey(key)
            toggleKey = key
        end
        
        function Window:Toggle()
            ToggleUI()
        end
        
        function Window:Show()
            if not isOpen then
                ToggleUI()
            end
        end
        
        function Window:Hide()
            if isOpen then
                ToggleUI()
            end
        end
        
        ThemeManager:OnThemeChange(function(newTheme)
            for _, element in pairs(Window.ThemeElements) do
                if element.Object and element.Property and element.ColorKey then
                    Creator.TweenObject(element.Object, TweenInfo.new(0.3), {[element.Property] = newTheme[element.ColorKey]}):Play()
                end
            end
        end)
        
        return Window
    end
    
    return Library
end)

return require(5)
