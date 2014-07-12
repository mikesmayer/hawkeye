// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require bootstrap-datepicker
//= require 'rest_in_place'
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree .


$(document).ready(function(){

/*
	var recipe_tbl = $('#menu_items_tbl').dataTable({
		"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
		"sPaginationType": "bootstrap",
		"bRetrieve": true,
		"aoColumnDefs": [
			{ 'bSortable': false, 
				'aTargets': [ 7, 8, 9 ] }
		]
	});
*/
	$('.datepicker').datepicker({
		format: 'yyyy/mm/dd',
		//endDate: '-1d',
		autoclose: false
	});

	$('#daterange').popover({
		html: true,
		content: "Test Content",
		placement: "bottom",
		container: "#daterange"
	});

	//JS for the meals index page
	if( $('#m4m_stats_tbl').length > 0 ){


		$.ajax({
			url: "meals/day_counts",
			cache: false,
			success: function(html){
				console.log(html);
				$('#m4m_stats_tbl').dataTable({
				  "sPaginationType": "bootstrap"
				});
			}
		});
	}

})
