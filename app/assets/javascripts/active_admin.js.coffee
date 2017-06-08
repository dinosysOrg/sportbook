#= require active_admin/base
#= require arctic_admin
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require summernote

$ ->
  $('.summernote').summernote()

$ ->
  $('.available-locales').remove()