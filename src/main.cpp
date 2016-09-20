#include <string.h>
#include <stdlib.h>
#include <cstdlib>

// Vita Specific
#include <psp2/appmgr.h>
#include <psp2/apputil.h>
#include <psp2/kernel/processmgr.h>
#include <psp2/kernel/modulemgr.h>
#include <psp2/kernel/processmgr.h>

// 2D Rendering Library
#include <vita2d.h>

// GWEN GUI Library
#include <Gwen/Gwen.h>
#include <Gwen/Platform.h>
#include <Gwen/Skins/Simple.h>
#include <Gwen/Skins/TexturedBase.h>
#include <Gwen/UnitTest/UnitTest.h>
#include <Gwen/Renderers/PSVita.h>
#include <Gwen/Input/Vita.h>
#include <Gwen/Controls/WindowCanvas.h>
#include <Gwen/Controls/ImagePanel.h>
#include <Gwen/Controls/ProgressBar.h>
#include <Gwen/Controls/Button.h>
#include <Gwen/Controls/CheckBox.h>
#include <Gwen/Controls/Label.h>

void quit(Gwen::Controls::Base *base) {
	sceKernelExitProcess(0);
}

int main(int argc, char *argv[]) {
	SceAppUtilInitParam initParam;
	SceAppUtilBootParam bootParam;
	memset(&initParam, 0, sizeof(SceAppUtilInitParam));
	memset(&bootParam, 0, sizeof(SceAppUtilBootParam));
	sceAppUtilInit(&initParam, &bootParam);

	// Initialize graphics
	vita2d_init();
	vita2d_set_clear_color(RGBA8(0x40, 0x40, 0x40, 0xFF));

	Gwen::Renderer::PSVita renderer("app0:/res/Roboto-Regular.ttf");

	Gwen::Skin::TexturedBase skin(&renderer);
	skin.Init("app0:/res/DefaultSkin.png");

	Gwen::Controls::Canvas *pCanvas = new Gwen::Controls::Canvas(&skin);

	pCanvas->SetSize(960, 544);
	pCanvas->SetDrawBackground(true);
	pCanvas->SetBackgroundColor(Gwen::Color(150, 170, 170, 255));

	Gwen::Controls::Button *pButton = new Gwen::Controls::Button(pCanvas);
	pButton->GetFont()->size = 18;
	pButton->SetText("Exit Application");
	pButton->SetPos(10, 10);
	pButton->SetSize(256, 48);
	Gwen::EventHandler exitPress(pButton->onPress, &quit);

	Gwen::Controls::WindowControl *pWindow = new Gwen::Controls::WindowControl(pCanvas);
	pWindow->SetTitle("Homebrew Window");
	pWindow->SetPos(400, 10);
	pWindow->SetSize(350, 150);

	Gwen::Controls::Label *pLabel = new Gwen::Controls::Label(pWindow);
	pLabel->SetText("I like cookies.\n - Banandana\nOriginal library by Garry Newman.");
	pLabel->SizeToContents();
	pLabel->SetPos(10, 10);

	// Create UI input handler
	Gwen::Input::Vita vitaInput;

	// Initialize it to the canvas
	vitaInput.Initialize(pCanvas);

	while (1) {
		// Begin rendering
		vita2d_start_drawing();

		// Render the canvas
		pCanvas->RenderCanvas();

		// End rendering
		vita2d_end_drawing();

		// Swap to screen
		vita2d_swap_buffers();

		// Update vita input
		vitaInput.Update();
	}

	vita2d_fini();

	sceKernelExitProcess(0);
	return 0;
}
