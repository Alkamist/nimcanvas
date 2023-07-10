{.experimental: "overloadableEnums".}

import std/strutils
import nimgui
import nimgui/widgets
import nimgui/backends
import opengl

const fontData = readFile("consola.ttf")

const sampleText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed consectetur metus et porta elementum.
Donec eget feugiat velit, in tincidunt velit.
Mauris et porta turpis, fringilla dapibus dolor.
Vestibulum vulputate faucibus velit, a facilisis tellus egestas eu.
Nullam ultricies sem vitae nisi finibus, elementum sollicitudin turpis placerat.
Curabitur ultricies ante scelerisque placerat fermentum.
Maecenas mattis dui eros, eget faucibus leo feugiat quis.
Nunc ultricies, enim a euismod tempus, risus erat rutrum diam, sed iaculis elit sapien at ante.
Nam vulputate arcu et bibendum aliquet. Nulla eget urna ligula.
Proin sollicitudin cursus enim, eu suscipit odio suscipit vitae.
Pellentesque a turpis nulla."""

let gui = Gui.new()

gui.setupBackend()
gui.addFont(fontData)
gui.show()

proc exampleWindow(gui: Gui, name: string, initialPosition: Vec2) =
  gui.pushIdSpace(gui.getId(name))

  const padding = 5.0
  const spacing = 5.0

  let positionId = gui.getId("Position")
  var position = gui.getState(positionId, initialPosition)

  let sizeId = gui.getId("Size")
  var size = gui.getState(sizeId, vec2(400, 300))

  gui.beginWindow("Window", position, size)

  # Header
  let header = gui.beginWindowHeader()
  gui.fillText(name, vec2(0, 0), header.size, alignment = vec2(0.5, 0.5))
  gui.endWindowHeader()

  # Body
  let body = gui.beginWindowBody()

  let sliderValueId = gui.getId("SliderValue")
  var sliderValue = gui.getState(sliderValueId, 0.0)
  let sliderPosition = vec2(padding, padding)
  let sliderSize = vec2(body.size.x - padding * 2.0, 24)
  gui.slider("Slider", sliderValue, sliderPosition, sliderSize)
  gui.setState(sliderValueId, sliderValue)

  let textScrollId = gui.getId("TextScroll")
  var textScroll = gui.getState(textScrollId, vec2(0, 0))
  let textPosition = vec2(sliderPosition.x, sliderPosition.y + sliderSize.y + spacing)
  let textSize = vec2(body.size.x - padding * 2.0, body.size.y - textPosition.y - padding)

  let textInteractionId = gui.getId("TextInteraction")
  if gui.mouseHitTest(textPosition, textSize):
    gui.requestHover(textInteractionId)

  if gui.isHovered(textInteractionId) and gui.mouseWheelMoved:
    textScroll.y += gui.mouseWheel.y * 32.0

  gui.pushClipRect(textPosition, textSize)
  gui.fillText(sampleText, textPosition + textScroll, textSize, alignment = vec2(sliderValue, 0))
  gui.popClipRect()

  gui.setState(textScrollId, textScroll)

  gui.endWindowBody()

  gui.endWindow()

  gui.setState(positionId, position)
  gui.setState(sizeId, size)

  gui.popIdSpace()

gui.onFrame = proc(gui: Gui) =
  glViewport(0, 0, GLsizei(gui.size.x), GLsizei(gui.size.y))
  glClearColor(49 / 255, 51 / 255, 56 / 255, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  gui.exampleWindow("Window1", vec2(50, 50))
  gui.exampleWindow("Window2", vec2(600, 50))
  gui.exampleWindow("Window3", vec2(50, 400))
  gui.exampleWindow("Window4", vec2(600, 400))

  gui.fillTextRaw("Fps: " & gui.fps.formatFloat(ffDecimal, 4), vec2(0, 0))

gui.run()