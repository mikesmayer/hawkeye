
function init_google_drive(){

	$('#get_folder_btn').click(function(){
		get_contents_tacos_daily_sales();
	});
	
}


function get_contents_tacos_daily_sales(){
	console.log("Getting files from Tacos Daily Sales folder in Drive");
	$.ajax({
		url: "google_drive_sync/file_list",
		data: { 
			folder_id: '0B3s566IfxmitZC1RckFyc3ZrZlk'
		}, 
		success: function(data){

			$('#gdrive_tacos_file_list').html(data);
			$('.view_folder').click(function(){
				folder_id = $(this).attr("id")
				folder_name = $(this).data("foldername");
				console.log(folder_id);

				get_folder_contents(folder_name, folder_id);				
			});
		}
	});	
}


function get_folder_contents(folder_name, folder_id){

	$.ajax({
		url: "google_drive_sync/folder",
		data: {
			folder_name: folder_name,
			folder_id: folder_id
		},
		success: function(data){
			$('#gdrive_folder_contents').html(data);
		}
	});

}
