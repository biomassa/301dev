local lib = require "msproc.libmsproc"
local Class = require "Base.Class"
local Unit = require "Unit"
local Pitch = require "Unit.ViewControl.Pitch"
local GainBias = require "Unit.ViewControl.GainBias"
local Gate = require "Unit.ViewControl.Gate"
local Encoder = require "Encoder"

local msproc = Class {}
msproc:include(Unit)

function msproc:init(args)
  args.title = "msproc"
  args.mnemonic = "MS"
  Unit.init(self, args)
end

function msproc:onLoadGraph(channelCount)
  local ms = self:addObject("ms", lib.msproc())

  local mAmount = self:addObject("mAmt", app.ParameterAdapter())
  local sAmount = self:addObject("sAmt", app.ParameterAdapter())

  tie(ms, "mAmt", mAmount, "Out")
  self:addMonoBranch("mBranch", mAmount, "In", mAmount, "Out")

  tie(ms, "sAmt", sAmount, "Out")
  self:addMonoBranch("sBranch", sAmount, "In", sAmount, "Out")

  connect(ms, "OutL", self, "Out1")
  connect(self, "In1", ms, "InL")

  if channelCount == 1 then
    connect(self, "In1", ms, "InR")
  else
    connect(self, "In2", ms, "InR")
    connect(ms, "OutR", self, "Out2")
  end
end

local views = {
  expanded = {
    "m",
	"s",
  },
  collapsed = {},
}

function msproc:onLoadViews(objects, branches)
  local controls = {}

  controls.m = GainBias {
    button = "m",
    description = "m",
    branch = branches.mBranch,
    gainbias = objects.mAmt,
    range = objects.mAmt,
    biasUnits = app.unitNone,
    biasMap = Encoder.getMap("[0,1]"),
    initialBias = 1,
  }

  controls.s = GainBias {
    button = "s",
    description = "s",
    branch = branches.sBranch,
    gainbias = objects.sAmt,
    range = objects.sAmt,
    biasUnits = app.unitNone,
	biasMap = Encoder.getMap("[0,1]"),
    initialBias = 1,
  }


  return controls, views
end

return msproc
