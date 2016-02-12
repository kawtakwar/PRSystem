    <link rel="stylesheet" href="static/css/jash.css"></link>
    <div style="font-size: 13px;margin: 5px;color: #000080;font-weight: bold;">Purchase Requisitions</div>
    <div id="prHeader" style="width:100%;position:relative;z-index:3;">
        <table id="prTable"></table>
        <div>&nbsp;</div>
        <!-- <input type="button" id="search" class="btn btn-primary" value="Search PR"/> -->
    </div>
    <style>
    .myLink { text-decoration: underline; cursor: pointer; }
    </style>
	<script>
		$(function () {
			var lastsel;
	        $("#prTable").jqGrid({
	            datatype:'local',
	            colNames:['PR No', 'Project Name', 'Project Code', 'Prepared Date', 'Prepared By', 'Status', 'Action','',''],
	            colModel:[
	                {name:'prNo', index:'prNo',key:true, width:80, sortable: false, align:'center', resizable: true, search:true/* , formatter: 'showlink', formatoptions: { baseLinkUrl: '', showAction: "editPR", idName:"prNo"}  */},
	                {name:'projectName', width:80, sortable: false, align:'left', resizable: true, search:false},
	                {name:'projectCode', width:80, sortable: false, align:'left', resizable: true, search:false},
	                {name:'createdDateStr', width:80, sortable: false, align:'left', resizable: true, search:false},
	                {name:'createdByName', width:80, sortable: false, align:'left', resizable: true, search:false},
	                {name:'status', index:'status', width:80, sortable: false, align:'center', resizable: true, search:false,editable: true,edittype:'select'},
	                {name:'select', index:'select',width:80, sortable: false, align:'center', resizable: true, search:false},
	                {name:'editable',  hidden:true},
	                {name:'allowedStatusChangesStr',  hidden:true}
				],
				width: $("#prHeader").width()-30,
	            height: "400",
	            scroll : true,
	            gridview : true,
	            loadtext: 'building list...',
	            jsonReader: {
	                repeatitems: false,
	            },
	            gridComplete: function(){ 
	                var ids = jQuery("#prTable").getDataIDs(); 
	                for(var i=0;i<ids.length;i++){ 
	                    var cl = ids[i]; 
	                    
	                    var rowData = jQuery("#prTable").getRowData(cl);
	                    var edit = "";
	                    if(rowData['editable'] == "true"){
	                    	edit = "<a id='edit' style='cursor:pointer;' href='editPR?prNo="+cl+"'><u>Edit</u></a> | ";
	                    }
	                    be = edit + "<a id='download' style='cursor:pointer;' href='rest/purchaseRequest/"+cl+"/download' download><u>Download</u></a> "; 
	                    jQuery("#prTable").setRowData(ids[i],{select:be}) 
	                } 
	            },
	            onSelectRow: function(id){
	        		if(id && id!==lastsel){
	        			jQuery('#prTable').jqGrid('restoreRow',lastsel);
        		        var cm = jQuery('#prTable').jqGrid('getColProp','status');
        		        var rowData = jQuery("#prTable").getRowData(id);
        		        var allowedStatusChanges = rowData['allowedStatusChangesStr'];
        		        allowedStatusChanges = allowedStatusChanges.replace("[","");
        		        allowedStatusChanges = allowedStatusChanges.replace("]","");
        		        if(allowedStatusChanges == ""){
        		        	allowedStatusChanges = "selected:" + rowData['status'];
        		        } else {
        		        	allowedStatusChanges = "selected:" + rowData['status']  + "," +allowedStatusChanges;
        		        }
        		        allowedStatusChanges = allowedStatusChanges.replaceAll(",",";");
        		        allowedStatusChanges = allowedStatusChanges.trim();
        		        if(allowedStatusChanges != ""){
            		        cm.editoptions = {value:allowedStatusChanges};
            		        cm.editoptions.dataEvents = [{ type: 'change', fn: function(e) {changeStatus(e,rowData['status'],rowData['prNo']); } }];
            		        jQuery('#prTable').jqGrid('editRow',id,true);
        		        }
	        			lastsel=id;
	        		}
	        	},
	            subGrid : true,
	            subGridOptions: { 
	            	"plusicon" : "ui-icon-triangle-1-e",
			     	"minusicon" :"ui-icon-triangle-1-s",
	                "openicon" : "ui-icon-arrowreturn-1-e",
	                "reloadOnExpand" : false,
	                "selectOnExpand" : true
	            },
	            subGridRowExpanded: function (subgridId, rowid) {
	            	
	            	var rowData = jQuery("#prTable").getRowData(rowid);
	            	var prNo = rowData['prNo'];
	            	var html = "";
	            	var priSubgridTableId = subgridId + "_pri";
            		$("#" + subgridId).html(html + "<div>&nbsp</div><div style='margin: 5px;color: #000080;font-weight: bold;'>Items - </div><table id='" + priSubgridTableId + "'></table><div>&nbsp</div>");
	                
	                $("#" + priSubgridTableId).jqGrid({
	                	datatype:'local',
	                	mtype: 'GET',
	                	colNames:['Description*', 'Total Qty required*', 'Qty In stock', 'Qty to be Purchased*', 'UOM', 'Unit Value', 'Approx. Total Value','Make','Cat No.','Required by date','Preferred Supplier'],
	        		    colModel:[
	        		        {name:'description', width:80, sortable: false, align:'center', resizable: true},
	        		        {name:'totalQuantityRequired', width:40, sortable: false, align:'center', resizable: true},
	        		        {name:'quantityInStock', width:40, sortable: false, align:'left', resizable: true},
	        		        {name:'quantityTobePurchased', width:40, sortable: false, align:'left', resizable: true},
	        		        {name:'uom', width:40, sortable: false, align:'left', resizable: true},
	        		        {name:'unitCost', width:30, sortable: false, align:'right', resizable: true},
	        		        {name:'approxTotalCost', width:40, sortable: false, align:'left', resizable: true},
	        		        {name:'make', width:40, sortable: false, align:'left', resizable: true},
	        		        {name:'catNo', width:40, sortable: false, align:'center', resizable: true},
	        		        {name:'requiredByDateStr', width:50, sortable: false, align:'center', resizable: true},
	        		        {name:'preferredSupplier', width:40, sortable: false, align:'center', resizable: true}
	        			],
	    				width: $("#prHeader").width()-111,
	                    height: '100%',
	                    loadtext: 'building list...',
	                    jsonReader: {
	                        repeatitems: false,
	                    },
	                    idPrefix: "sd_" + rowid + "_",
	                    jsonReader: {
	                        repeatitems: false,
	                    },
	                    loadError: function(jqXHR, status, error) {
	                    	if( jqXHR.status == 401 ) {
	                        	alert('Session Expired');            		
	                    	} else if( jqXHR.responseText.length == 0 ) {
	                    		alert('Service Unavailable');
	                    	} else {
	                        	alert(jqXHR.statusText);
	                    	}
	                    }
	                });
	                
	                $(".ui-jqgrid .subgrid-data .ui-th-column").each(function() {
	                	var HeaderFontColor = "#48b8e5";
	                	this.style.color = HeaderFontColor;
	               	});
	                
	            	var getPrItemsUrl =  "rest/purchaseRequest/"+prNo+"/items";
	            	$("#"+priSubgridTableId).jqGrid().setGridParam({url : getPrItemsUrl, page : 1, datatype : "json"});
	                $("#"+priSubgridTableId).jqGrid().trigger('reloadGrid');
	                
	            },
	            loadError: function(jqXHR, status, error) {
	            	if( jqXHR.status == 401 ) {
	                	jQuery("#prTable").html('<div style="height: 205px">Session Expired</div>');            		
	            	} else if ( jqXHR.responseText.length == 0 ) {
	            		jQuery("#prTable").html('<div style="height: 205px">Service Unavailable</div>');
	            	} else {
	                	jQuery("#prTable").html('<div style="height: 205px">' + jqXHR.statusText + '</div>');
	            	}
	            },
	            rownumbers: true
	        });
	        String.prototype.replaceAll = function(search, replacement) {
	            var target = this;
	            return target.replace(new RegExp(search, 'g'), replacement);
	        };
	        function changeStatus(e,prevStatus,prNo) {
	        	if(e.target.selectedOptions[0].textContent != prevStatus){
	        		$.ajax({
	        			type:'PUT',
	        			url: 'rest/purchaseRequest/'+prNo+'/updatestatus?status='+e.target.selectedOptions[0].value,
	        			success: function(data, status, jqXHR ){
	        					alert("Updated Successfully!!");
	        					$("#prTable").jqGrid().trigger('reloadGrid');
	        			},
	                    error : function(jqXHR, status, error) {
	                    	if( jqXHR.status == 401 ) {
	                        	alert('Session Expired');            		
	                    	} else {
	                    		alert(jqXHR.statusText);
	                    	}
	                    }
	        		});
	        	}
	        }
	        var newUrlUsersTable = "rest/purchaseRequest/_search";
	        $("#prTable").jqGrid().setGridParam({
	    		url : newUrlUsersTable, 
	    		page : 1, 
	    		mtype:'POST',
	    		datatype : "json",
				ajaxGridOptions: { 
					type :'POST',
					contentType :"application/json; charset=utf-8"
				},
				serializeGridData: function(postData) {
					postData['pageSize'] =  defaultPageSize;
				    return JSON.stringify(postData);
				}
	    	});
	         $("#prTable").jqGrid().trigger('reloadGrid');
	         
	         $("#search").click(function(){
	        	 var options = {
		        	     caption: "Search...",
		        	     Find: "Find",
		        	     Reset: "Reset",
		        	     sopt : ['cn']
		        	   };
		        jQuery("#prTable").jqGrid('searchGrid', options );
	         });
	         
	         $("#fbox_prTable_search").click(function(){
		        	alert("got the click!!!"); 
		     });
	   });
	</script>