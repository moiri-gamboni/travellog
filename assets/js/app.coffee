"use strict"

module = angular.module("mainModule", ["mainModule.services", "mainModule.controllers"])

module.run () ->
	console.log("run")
