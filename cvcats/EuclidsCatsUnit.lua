local app = app
local libFoo = require "tutorial.libFoo"
local Class = require "Base.Class"
local Unit = require "Unit"
local Fader = require "Unit.ViewControl.Fader"
local Gate = require "Unit.ViewControl.Gate"
local CatCircle = require "tutorial.CatCircle"
local GainBias = require "Unit.ViewControl.GainBias"
local Encoder = require "Encoder"

local EuclidsCatsUnit = Class {}
EuclidsCatsUnit:include(Unit)

function EuclidsCatsUnit:init(args)
  args.title = "Euclid's CVCats"
  args.mnemonic = "Eu"
  Unit.init(self, args)
end

function EuclidsCatsUnit:onLoadGraph(channelCount)
  local clockComparator = self:addObject("clockComparator", app.Comparator())
  clockComparator:setTriggerMode()
  local resetComparator = self:addObject("resetComparator", app.Comparator())
  resetComparator:setTriggerMode()
  local cats = self:addObject("cats", app.GainBias())
  local catsRange = self:addObject("catsRange", app.MinMax())
  local euclid = self:addObject("euclid", libFoo.EuclideanSequencer(32))

  connect(clockComparator, "Out", euclid, "Trigger")
  connect(resetComparator, "Out", euclid, "Reset")
  connect(cats, "Out", euclid, "Cats")
  connect(euclid, "Out", self, "Out1")
  connect(cats, "Out", catsRange, "In")

  self:addMonoBranch("clock", clockComparator, "In", clockComparator, "Out")
  self:addMonoBranch("reset", resetComparator, "In", resetComparator, "Out")
  self:addMonoBranch("catsBranch", cats, "In", cats, "Out")

  if channelCount > 1 then connect(euclid, "Out", self, "Out2") end
end

local views = {
  expanded = {
    "clock",
    "reset",
    "cats",
    "boxes",
    "circle"
  },
  collapsed = {}
}

function EuclidsCatsUnit:onLoadViews(objects, branches)
  local controls = {}

  controls.clock = Gate {
    button = "clock",
    description = "Clock Input",
    branch = branches.clock,
    comparator = objects.clockComparator
  }

  controls.reset = Gate {
    button = "reset",
    description = "Reset Input",
    branch = branches.reset,
    comparator = objects.resetComparator
  }
  controls.cats = GainBias {
    button = "cats",
    branch = branches.catsBranch,
    description = "Cat Count",
    gainbias = objects.cats,
    range = objects.catsRange,
    biasMap = Encoder.getMap("int[0,32]"),
    biasUnits = app.unitNone,
    initialBias = 0,
    biasPrecision = 0,
    gainPrecision = 0,
    initialGain = 5,
    gainMap = Encoder.getMap("int[-32,32]"),
  }
  -- controls.cats = Fader {
  --  button = "cats",
  --  description = "Cat Count",
  --  param = objects.euclid:getParameter("Cats"),
  --  monitor = self,
  --   Using canned map (if the one you need is not available, you can create your own.)
  --  map = Encoder.getMap("int[0,32]"),
  --  precision = 0,
  --  initial = 0,
  --  units = app.unitNone
  -- }

  controls.boxes = Fader {
    button = "boxes",
    description = "Box Count",
    param = objects.euclid:getParameter("Boxes"),
    monitor = self,
    -- Using canned map (if the one you need is not available, you can create your own.)
    map = Encoder.getMap("int[1,32]"),
    precision = 0,
    initial = 1,
    units = app.unitNone
  }

  controls.circle = CatCircle {
    sequencer = objects.euclid
  }

  return controls, views
end

return EuclidsCatsUnit
