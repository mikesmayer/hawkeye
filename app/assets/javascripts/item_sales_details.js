
function init_item_sales_detail_page(){
	item_sales_breakdown_granulatrity = "month";
	item_sales_index_date_range = "current_year";
	selected_restaurant = "p42";

	update_item_sales_details();
	update_details_csv_download_url();
	
	item_sales_setup_click_handlers();
}




function update_item_sales_details(){

	//$('#item-sales-table').dataTable().fnClearTable();

	$('#item-sales-table').dataTable({
		"bDestroy": true,
	  	"sPaginationType": "bootstrap",
	    "processing": true,
	    "serverSide": true,
	    //"ajax": $('#item-sales-table').data('source'),
	    "ajax": "sales_details.json?date_range="+item_sales_index_date_range+"&restaurant="+selected_restaurant,
	    "pagingType": "simple_numbers",
	    "stateSave": true,
	    "bFilter": false
	});

	//?granularity="+item_sales_breakdown_granulatrity
}

function update_details_csv_download_url(){
	$('#item_sales_csv_btn').html("<a class=\"btn btn-primary btn-xs pull-right\" href=\"/item_sales/sales_details.csv?date_range="+item_sales_index_date_range+"&restaurant="+selected_restaurant+"\">Download CSV</a>");
}