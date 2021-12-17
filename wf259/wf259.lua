local lib = require "wf259.libwf259"
local Class = require "Base.Class"
local Unit = require "Unit"
--local Pitch = require "Unit.ViewControl.Pitch"
local GainBias = require "Unit.ViewControl.GainBias"
--local Gate = require "Unit.ViewControl.Gate"
local Encoder = require "Encoder"

local wf259 = Class {}
wf259:include(Unit)

function wf259:init(args)
  args.title = "wf259"
  args.mnemonic = "WF"
  Unit.init(self, args)
end

function wf259:onLoadGraph(channelCount)
  local wf = self:addObject("wf", lib.wf259())

  local fldAmount = self:addObject("fold", app.ParameterAdapter())
  local offAmount = self:addObject("offset", app.ParameterAdapter())
  local lpAmount = self:addObject("lowpass", app.ParameterAdapter())

  tie(wf, "fold", fldAmount, "Out")
  self:addMonoBranch("fldBranch", fldAmount, "In", fldAmount, "Out")

  tie(wf, "offset", offAmount, "Out")
  self:addMonoBranch("offBranch", offAmount, "In", offAmount, "Out")

  tie(wf, "lowpass", lpAmount, "Out")
  self:addMonoBranch("lpBranch", lpAmount, "In", lpAmount, "Out")

  connect(wf, "OutL", self, "Out1")
  connect(self, "In1", wf, "InL")

	  -- looky here if this doesn't compile!

  if channelCount == 1 then
    connect(self, "In1", wf, "InR")
  else
    connect(self, "In2", wf, "InR")
    connect(wf, "OutR", self, "Out2")
  end
end

local views = {
  expanded = {
    "f",
	"o",
	"l",
  },
  collapsed = {},
}

function wf259:onLoadViews(objects, branches)
  local controls = {}

  controls.f = GainBias {
    button = "fld",
    description = "Fold",
    branch = branches.fldBranch,
    gainbias = objects.fold,
    range = objects.fold,
    biasUnits = app.unitNone,
    biasMap = Encoder.getMap("[0,1]"),
    initialBias = 0,
  }

  controls.o = GainBias {
    button = "off",
    description = "offset",
    branch = branches.offBranch,
    gainbias = objects.offset,
    range = objects.offset,
    biasUnits = app.unitNone,
	biasMap = Encoder.getMap("[-1,1]"),
    initialBias = 0,
  }

  controls.l = GainBias {
    button = "LP",
    description = "lowpass",
    branch = branches.lpBranch,
    gainbias = objects.lowpass,
    range = objects.lowpass,
    biasUnits = app.unitNone,
    biasMap = Encoder.getMap("[0,1]"),
    initialBias = 1
}


  return controls, views
end

return wf259
