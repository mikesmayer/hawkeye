
function init_google_drive(){
	$('#error_container').hide();

	$('#get_folder_btn').click(function(){
		get_contents_tacos_daily_sales();
	});
	
	$('#get_p42_folder_btn').click(function(){
		get_contents_p42_daily_sales();
	});
	
	$('#search_drive_btn').click(function( event ){
		event.preventDefault();
		var search_term = $('#search_term').val();
		search_drive(search_term);
	});	
	

}


function get_contents_tacos_daily_sales(){
	console.log("Getting files from Tacos Daily Sales folder in Drive");
	$.ajax({
		url: "google_drive_sync/folder",
		data: { 
			folder_id: '0B3s566IfxmitZC1RckFyc3ZrZlk',
			scope: 'all'
		}, 
		beforeSend: function() {
			$('#get_folder_btn').prop('disabled', true);
			$('#get_folder_btn').html('Searching...');
			$('#gdrive_tacos_file_list').empty();
		},
		success: function(data){
			$('#get_folder_btn').prop('disabled', false);
			$('#get_folder_btn').html('Get Folder');
			$('#gdrive_tacos_file_list').html(data);

			view_folder_click_handler();
		}
	});	
}

function get_contents_p42_daily_sales(){
	console.log("Getting files from P42 Reports folder in Drive");
	$.ajax({
		url: "google_drive_sync/folder",
		type: 'GET',
		data: { 
			folder_id: '0B3s566IfxmitNVcwTE9rY0JkYmM',
			scope: 'all'
		},
		beforeSend: function() {
			$('#error_container').hide();

			$('#get_p42_folder_btn').prop('disabled', true);
			$('#get_p42_folder_btn').html('Searching...');
			$('#gdrive_p42_file_list').empty();
		},
		error: function(data){
			console.log(data);
			$('#error_container').html(data.statusText + ". Try again or use search.");
			$('#error_container').show();
			$('#get_p42_folder_btn').prop('disabled', false);
			$('#get_p42_folder_btn').html('Get folder');
		},
		success: function(data){


			$('#get_p42_folder_btn').prop('disabled', false);
			$('#get_p42_folder_btn').html('Get folder');
			$('#gdrive_p42_file_list').html(data);

			$('.process_file').click(function(){
				file_id = $(this).data("fileid");
				process_p42_csv(file_id);
			});
		}
	});	
}

function get_folder_contents(folder_name, folder_id, scope, button_id){

	$.ajax({
		url: "google_drive_sync/folder",
		data: {
			folder_name: folder_name,
			folder_id: folder_id,
			scope: scope
		},
		success: function(data){
			$('#gdrive_folder_contents').html(data);
			$('#process_day').click(function(){
				var cat_dbf_file_id = $("#CAT").data("fileid");
				process_dbf("CAT", cat_dbf_file_id);
				
			});

			$('#'+button_id).prop('disabled', false);
			if(scope == "all"){
				$('#'+button_id).html("View Contents");
			}else{
				$('#'+button_id).html("View Filtered");
			}
			
		}
	});

}

function process_dbf(file_type, file_id){
	console.log("Processing day flow, starting: " + file_type);

	$.ajax({
		url: "google_drive_sync/get_file",
		type: "GET",
		data: {
			file_id: file_id
		},
		beforeSend: function(){
			$('#'+file_type+'-results').html("<span class=\"label label-default\">Processing...</span>");
		},
		success: function(data){
			console.log(data);

			var span_class = "label label-success";
			var label_contents = "<b>Processed:</b> " + data.num_processed;

			if(data.creates > 0){
				label_contents += " | <b>Created:</b> " + data.creates;
			}
			
			if(data.updates > 0){
				label_contents += " | <b>Updated:</b> " + data.updates;
			}			

			if(data.errors > 0){
				span_class = "label label-danger";
				label_contents += "| <b>Errors:</b> " + data.errors;
			}
			
			$('#'+file_type+'-results').html("<span class=\""+span_class+"\">"+label_contents+"</span>");
			
			if(file_type == "CAT"){
				var itm_dbf_file_id = $("#ITM").data("fileid");
				process_dbf("ITM", itm_dbf_file_id);
			}else if(file_type == "ITM"){
				var cit_dbf_file_id = $("#CIT").data("fileid");
				process_dbf("CIT", cit_dbf_file_id);
			}else if(file_type == "CIT"){
				var gnditem_dbf_file_id = $('#GNDITEM').data("fileid");
				process_dbf("GNDITEM", gnditem_dbf_file_id);
			}else if(file_type == "GNDITEM"){
				var gndvoid_dbf_file_id = $('#GNDVOID').data("fileid");
				process_dbf("GNDVOID", gndvoid_dbf_file_id);
			}
			
		}
	});

}


function process_p42_csv(file_id){
	console.log("Process P42 Item Sales CSV");

	$.ajax({
		url: "google_drive_sync/get_file",
		type: "GET",
		cache: false,
		data: {
			file_id: file_id
		},
		beforeSend: function(){
			$('#error_container').hide();
			$('#csv-'+file_id).prop('disabled', true);
			$('#csv-'+file_id).html('Processing...');
		},
		error: function(data){
			$('#error_container').html(data.statusText + ". Try again or use search.");
			$('#error_container').show();
			$('#csv-'+file_id).prop('disabled', false);
			$('#csv-'+file_id).html('Process');
		},
		success: function(data){
			console.log("P42 CSV success");
			var result_html = "<h4>Results</h4>";
			result_html += "<b>Number Processed:</b> " + data.num_processed;

			if(data.creates > 0){
				result_html += "<br /><b>Created:</b> " + data.creates;
			}
			
			if(data.updates > 0){
				result_html += "<br /><b>Updated:</b> " + data.updates;
			}			

			if(data.errors > 0){
				result_html += "<br /><b>Errors:</b> " + data.errors;
			}

			$('#file_parse_results').html(result_html);
			$('#csv-'+file_id).html('Processed');
		}
	});


}

function search_drive(search_term){
	console.log("Searching for - " + search_term);
	$.ajax({
		url: "google_drive_sync/search",
		type: "GET",
		data: {
			search_term: "title contains '" + search_term + "'"
		},
		beforeSend: function() {
			$('#search_drive_btn').prop('disabled', true);
			$('#search_drive_btn').prop('value', 'Searching...');
			$('#drive_search_container').empty();
		},
		success: function(data){
			//console.log(data);
			$('#search_drive_btn').prop('disabled', false);
			$('#search_drive_btn').prop('value', 'Search');

			$('#drive_search_container').html(data);

			view_folder_click_handler();

		}
	});
}

function view_folder_click_handler(){
	$('.view_folder').click(function(){
		button_id = $(this).attr("id")
		folder_id = $(this).data("folderid");
		folder_name = $(this).data("foldername");
		scope = $(this).data("scope");

		//console.log(folder_id);
		$(this).prop('disabled', true);
		$(this).html("Processing...");

		get_folder_contents(folder_name, folder_id, scope, button_id);				
	});
}
