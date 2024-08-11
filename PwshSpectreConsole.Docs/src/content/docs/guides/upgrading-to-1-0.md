# Upgrading to 1.0

I started this as a learning excercise in how to bridge the gap between C# libraries and PowerShell and wow have I learned a lot. Things I thought made sense when I first wrote this have now made it difficult to maintain. I've tried to maintain as much backwards compatibility as I can but there are some areas which will have breaking changes when upgrading to 1.0.

## New Features

- Renderable items use PowerShell formatters (thanks @startautomating) so you can now assign the output of functions like `Format-SpectreJson` to a variable and use it inside other Spectre Console functions like `Format-SpectreTable`.

## Changes

- Parameter names for a lot of commandlets have been aligned with the terminology in Spectre.Console, this affects commands all throughout this module but to maintain backwards compatibility the old parameter names have been kept as aliases so existing scripts will continue to work. Exceptions to this are:
  - Format-SpectreJson parameters removed are `-Border`, `-Title`, `-NoBorder`. To wrap the json in a border the suggested option is to pipe the output to Format-SpectrePanel e.g. `Format-SpectreJson -Data $data | Format-SpectrePanel`
  - TODO find the others
