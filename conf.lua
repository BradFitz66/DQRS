function love.conf(t)
	t.console=true
	t.title="Testing";
	t.window.resizable = true
	t.window.width=256
	t.window.height=384
	t.window.minwidth = 256            
    t.window.minheight = 384
	t.vsync=false;


	t.modules.mouse    = false
	t.modules.physics  = false
	t.modules.thread   = false
	t.modules.touch    = false
	t.modules.video    = false
end