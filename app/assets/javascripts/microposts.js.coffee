# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

changeCountdown = ->
  remaining = 140 - $('#micropost_content').val().length
  $('.countdown_indicator').text remaining + ' characters remaining.'

$(document).ready ->
  changeCountdown()
  $('#micropost_content').keyup changeCountdown
  $('#micropost_content').change changeCountdown


