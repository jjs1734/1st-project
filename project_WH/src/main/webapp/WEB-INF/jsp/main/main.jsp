<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>탄소 배출 지도</title>
<!-- 구글 차트 -->
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<!-- 아이콘 -->
<script src="https://kit.fontawesome.com/ee661efb4b.js" crossorigin="anonymous"></script>
<script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
<!-- 제이쿼리 -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript">

$(document).ready(function() {
let sdLayer;
let sggLayer;
let bjdLayer;
let overlay;


	// 통계

	function drawCharts(chartData, chartValue) {

		google.charts.load('current', {
			packages: ['corechart', 'table']
		}).then(function() {
			drawBarChart(chartData, chartValue);
			drawTableChart(chartData, chartValue);
		});
		
	}
	
	function drawBarChart(chartData, chartValue) {
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Region');
		data.addColumn('number', 'Total Usage');
		
		chartData.forEach(function(item) {
			var regionName = chartValue == 1 ? item.sd_nm : item.sgg_nm;
			data.addRow([regionName, item.totalusage]);
		});
		var option = {
				height: 400,
				hAxis: {
		            title: '전력 사용량 (단위 : KWh)',
		            textStyle: {
		                color: '#000000',
		                fontSize: 13,
		                bold: true
		            },
		            titleTextStyle: {
		                color: '#000000',
		                fontSize: 15,
		                bold: true
		            }
		        },
		        vAxis: {
		            title: '지역',
		            textStyle: {
		                color: '#000000',
		                fontSize: 13
		            },
		            titleTextStyle: {
		                color: '#000000',
		                fontSize: 15,
		                bold: true
		            }
		        },
		        colors: ['#368AFF'],
		        backgroundColor: '#FFFFFF',
		        chartArea: {
		            width: '60%',
		            height: '80%'
		        },
		        legend: { position: 'none' }
		};
		var chart = new google.visualization.BarChart(document.getElementById('barChart'));
		chart.draw(data, option);
	}
	
	function drawTableChart(chartData, chartValue) {
	    var data = new google.visualization.DataTable();
	    data.addColumn('string', '지역');
	    data.addColumn('number', '전력 사용량 (단위 : KWh)');
	    
	 
	    	
	    chartData.forEach(function(item) {
			var regionName = chartValue == 1 ? item.sd_nm : item.sgg_nm;
			data.addRow([regionName, item.totalusage]);
		});
	    	
	    
	    
	    var table = new google.visualization.Table(document.getElementById('tableChart'));
	    table.draw(data, {showRowNumber: true, width: '100%', height: '500px'});
	}
	
	$('#chartBtn').click(function(){
		var chartValue = $('#chartSelect').val();
		
		if(chartValue >= 1) {
			modal.style.display = "block"; // 모달 창 표시

			if (chartValue == 1){
				$.ajax({
					type : "POST",
					url : "/sdChartData.do",
					dataType : 'text',
					success : function(response) {
						//alert('AJAX 요청 성공!');
						var chartData = JSON.parse(response);
						drawCharts(chartData, chartValue);
					},
					error : function(xhr, status, error) {
						alert('ajax 실패');

					}
				});
				
			} else {
				
				$.ajax({
					type : "POST",
					url : "/sggChartData.do",
					data : { "sd" : chartValue },
					dataType : 'text',
					success : function(response) {
						//alert('AJAX 요청 성공!');
						var chartData = JSON.parse(response);
						drawCharts(chartData, chartValue);
					},
					error : function(xhr, status, error) {
						alert('ajax 실패');

					}
				});
				
			}
			
			
		} else {
			alert('시/도를 선택 후 검색을 눌러주세요.');
		}
		
	});
	
	
	
	
	
	
	
	
	
	
	
	
	// 모달
	
	var modal = document.getElementById("chartModal");
	
	var closeButton = document.querySelector(".close-button");
	
	window.onclick = function(event) {
	    if (event.target == modal) {
	        modal.style.display = "none";
	    }
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// 검색
	
	$('#sdSelect').change(function(){
		
		// 기존 sdLayer 존재 시 삭제
		if (sdLayer || sggLayer || bjdLayer) {
			map.removeLayer(sdLayer);
			map.removeLayer(sggLayer);
			map.removeLayer(bjdLayer);
		}
		
		if(overlay) {
			map.removeOverlay(overlay);
		}
		var bjdSelect = $("#bjdSelect");
		bjdSelect.html("<option>--법정동을 선택하세요--</option>");
		
		var sdValues = $(this).val();
		var sdText = $(this).find('option:selected').text()
		var sdValuesSplit = sdValues.split(",");
		var sdCd = sdValuesSplit[0];
		var sdX = sdValuesSplit[1];
		var sdY = sdValuesSplit[2];
		var sdArea = sdValuesSplit[3];
		var sdCenter = ol.proj.fromLonLat([sdX, sdY]);
	
		map.getView().setCenter(sdCenter);
		if (sdArea > 10000) {
			map.getView().setZoom(9);
		} else if (sdArea > 5000) {
			map.getView().setZoom(10);
		} else {
			map.getView().setZoom(11);
		}
		
		
		// 시,도 레이어
		sdLayer = new ol.layer.Tile({
					source : new ol.source.TileWMS({
								url : 'http://localhost:8080/geoserver/jinsu/wms?service=WMS',
								params : {
									'VERSION' : '1.1.0', // 
									'LAYERS' : 'jinsu:tl_sd', //
									'CQL_FILTER': 'sd_cd=' + sdCd,
									'BBOX' : [
											1.3867446E7,
											3906626.5,
											1.4684055E7,
											4670269.5 ],
									'SRS' : 'EPSG:3857',
									'FORMAT' : 'image/png'
								},
								serverType : 'geoserver',
							})
				});
		
		map.addLayer(sdLayer); // 맵에 레이어를 추가
		
		
		$.ajax({
			type : "POST", //
			url : "/getSgg.do",
			data : { "sd" : sdText },
			dataType : 'text',
			success : function(
					response) {
				//alert('AJAX 요청 성공!');

				var sgg = JSON.parse(response);

				var sggSelect = $("#sggSelect");
				sggSelect.html("<option>--시/군/구를 선택하세요--</option>");
				for (var i = 0; i < sgg.length; i++) {
					var item = sgg[i];
					sggSelect.append("<option value='" + item.sgg_cd + "," + item.sgg_x + "," + item.sgg_y + "," + item.sgg_area + "'>" + item.sgg_nm + "</option>");
				}
			},
			error : function(xhr, status, error) {
				// 에러 발생 시 수행할 작업
				alert('ajax 실패');
				// console.error("AJAX 요청 실패:", error);
			}
		});
	});
	
	$('#sggSelect').change(function(){
		
		if(sdLayer || sggLayer || bjdLayer) {
			map.removeLayer(sdLayer);
			map.removeLayer(sggLayer);
			map.removeLayer(bjdLayer);
		}
		
		if(overlay) {
			map.removeOverlay(overlay);
		}
		
		var sggValues = $(this).val();
		var sggText = $(this).find('option:selected').text()
		var sggValuesSplit = sggValues.split(",");
		var sggCd = sggValuesSplit[0];
		var sggX = sggValuesSplit[1];
		var sggY = sggValuesSplit[2];
		var sggArea = sggValuesSplit[3];
		var sggCenter = ol.proj.fromLonLat([sggX, sggY]);
		
		map.getView().setCenter(sggCenter);
		if (sggArea > 1000) {
			map.getView().setZoom(10);
		} else if (sggArea > 500) {
			map.getView().setZoom(11);
		} else if (sggArea > 100) {
			map.getView().setZoom(12);
		} else {
			map.getView().setZoom(13);
		}
		
		
		sggLayer = new ol.layer.Tile(
				{ // sgg 시군구
					source : new ol.source.TileWMS(
							{
								url : 'http://localhost:8080/geoserver/jinsu/wms?service=WMS', // 1. 레이어 URL
								params : {
									'VERSION' : '1.1.0', // 2. 버전
									'LAYERS' : 'jinsu:tl_sgg', // 3. 작업공간:레이어 명
									'CQL_FILTER': 'sgg_cd=' + sggCd,
									'BBOX' : [ 1.386872E7,
											3906626.5,
											1.4428071E7,
											4670269.5 ],
									'SRS' : 'EPSG:3857',
									'FORMAT' : 'image/png' 
								},
								serverType : 'geoserver',
							})
				});

		map.addLayer(sggLayer);
		
		$.ajax({
			type : "POST", //
			url : "/getBjd.do",
			data : { "sgg" : sggCd },
			dataType : 'text',
			success : function(response) {
				//alert('AJAX 요청 성공!');
				var bjd = JSON.parse(response);
				
				var bjdSelect = $("#bjdSelect");
				bjdSelect.html("<option>--동/읍/면을 선택하세요--</option>");
				for (var i = 0; i < bjd.length; i++) {
					var item = bjd[i];
					bjdSelect.append("<option value='" + item.bjd_cd + "," + item.bjd_x + "," + item.bjd_y + "," + item.bjd_area + "'>" + item.bjd_nm + "</option>");
				}
			},
			error : function(xhr, status, error) {
				alert('getBjd ajax 실패');
			}
		});
		
	});
	
	
$('#bjdSelect').change(function(){
		
		if(sdLayer || sggLayer || bjdLayer) {
			map.removeLayer(sdLayer);
			map.removeLayer(sggLayer);
			map.removeLayer(bjdLayer);
		}
		
		if(overlay) {
			map.removeOverlay(overlay);
		}
		
		var bjdValues = $(this).val();
		var bjdText = $(this).find('option:selected').text()
		var bjdValuesSplit = bjdValues.split(",");
		var bjdCd = bjdValuesSplit[0];
		var bjdX = bjdValuesSplit[1];
		var bjdY = bjdValuesSplit[2];
		var bjdArea = bjdValuesSplit[3];
		var bjdCenter = ol.proj.fromLonLat([bjdX, bjdY]);
		
		map.getView().setCenter(bjdCenter);
		if (bjdArea > 50) {
			map.getView().setZoom(12);
		} else if (bjdArea > 20){
			map.getView().setZoom(13);
		} else {
			map.getView().setZoom(14);
		}
		
		bjdLayer = new ol.layer.Tile(
				{ // sgg 시군구
					source : new ol.source.TileWMS(
							{
								url : 'http://localhost:8080/geoserver/jinsu/wms?service=WMS', // 1. 레이어 URL
								params : {
									'VERSION' : '1.1.0', // 2. 버전
									'LAYERS' : 'jinsu:tl_bjd', // 3. 작업공간:레이어 명
									'CQL_FILTER': 'bjd_cd=' + bjdCd,
									'BBOX' : [ 1.3873946E7,
										3906626.5,
										1.4428045E7,
										4670269.5 ],
									'SRS' : 'EPSG:3857',
									'FORMAT' : 'image/png' 
								},
								serverType : 'geoserver',
							})
				});

		map.addLayer(bjdLayer);
		
		$.ajax({
			type : "POST", //
			url : "/getEle.do",
			data : { "bjdCd" : bjdCd },
			dataType : 'text',
			success : function(response) {
				//alert('AJAX 요청 성공!');
				var ele = JSON.parse(response);

				var overlayElement = document.createElement('div');
			    overlayElement.style.backgroundColor = 'white'; // 배경색을 흰색으로 설정
			    overlayElement.style.border = '1px solid black'; // 테두리 추가
			    overlayElement.style.padding = '5px'; // 안쪽 여백 추가
			    overlayElement.style.borderRadius = '5px'; // 모서리 둥글게
			    overlayElement.style.opacity = '0.7'; // 배경 투명도 설정 (0 완전 투명 ~ 1 완전 불투명)
			    
			    overlayElement.innerHTML = bjdText + '의 전력 사용량은 ' + ele + 'KWh 입니다'; // 오버레이에 표시될 내용
			    var overlay = new ol.Overlay({
			        element: overlayElement,
			        position: ol.proj.fromLonLat([bjdX, bjdY]),
			        positioning: 'bottom-center'
			    });
			    map.addOverlay(overlay);
				
			},
			error : function(xhr, status, error) {
				alert('getEle ajax 실패');
			}
		}); 
		
	});
	
	
	
	// 맵 생성
	let map = new ol.Map(
			{
				target : 'map', // 맵 객체를 연결하기 위한 <div>의 id값을 지정
				layers : [
				new ol.layer.Tile(
						{
							source : new ol.source.OSM(
									{
										url : 'https://api.vworld.kr/req/wmts/1.0.0/785143F3-50EE-3760-AF52-103A8D296D30/Base/{z}/{y}/{x}.png' // vworld의 지도를 가져온다.
									})
						}) ],
				view : new ol.View({
					center : ol.proj.fromLonLat([128, 36]),
					zoom : 8
				})
			});
	
});
</script>
<style type="text/css">
    .menu {
        position: fixed;
        left: 0;
        top: 0;
        width: 250px;
        height: 100%;
        background-color: #8FBC8F;
        transition: 0.5s;
        z-index: 100; /* 메뉴가 맵 위에 나타나도록 z-index 설정 */
        box-shadow: 10px 0 15px -5px rgba(0, 0, 0, 0.5); /* 그림자 추가 */
    }

    .map {
        height: 942px;
        min-width: 85%; /* .map의 최소 너비 설정 */
    }

    .selectBar select {
        display: block;
        width: 100%;
        margin: 10px 0;
    }

h3 {
	color: white;
}


/* 모달 창 전체 스타일 */
.modal {
    display: none; /* 기본적으로 숨김 */
    position: fixed; /* 페이지 위에 고정 */
    z-index: 200; /* 모든 것 위에 */
    left: 0;
    top: 0;
    width: 100%; /* 전체 너비 */
    height: 100%; /* 전체 높이 */
    background-color: rgb(0, 0, 0); /* 백그라운드 색 */
    background-color: rgba(0, 0, 0, 0.4); /* 약간의 투명도 */
}

/* 모달 내용 스타일 */
.modal-content {
    background-color: #fefefe;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 80%; /* 너비 */
    height: 80%;
    padding: 20px;
    border: 1px solid #888;
	overflow-y: auto;
}
.google-visualization-table-table {
    font-family: Arial, sans-serif;
    border-collapse: separate;
    border-spacing: 2px;
}

.google-visualization-table-th, .google-visualization-table-td {
    border: 1px solid #ccc;
    text-align: center;
}

.google-visualization-table-th {
    background-color: #f5f5f5;
    font-weight: bold;
    color: #333;
}
</style>
<body>
	<div class="menu">
		
		<h3>&nbsp;<i class="fa-solid fa-magnifying-glass"></i>&nbsp;검색</h3>
		
		<div class="selectBar">
			<select id="sdSelect">
				<option>--시/도를 선택하세요--</option>
					<c:forEach items="${sd }" var="sd">
						<option value="${sd.sd_cd },${sd.sd_x},${sd.sd_y},${sd.sd_area}">${sd.sd_nm }</option>
					</c:forEach>
			</select>
		</div>
		
		<div class="selectBar">
				<select id="sggSelect">
					<option>--시/군/구를 선택하세요--</option>
				</select>
		</div>

		<div class="selectBar">
				<select id="bjdSelect">
					<option>--동/읍/면을 선택하세요--</option>
				</select>
		</div>
		
				
		
		<br>
		
		<h3>&nbsp;<i class="fa-solid fa-chart-simple"></i>&nbsp;통계</h3>
			<div class="selectBar">
				<select id="chartSelect">
					<option>--시/도를 선택하세요--</option>
					<option value="1">전체 선택</option>
						<c:forEach items="${sd }" var="sd">
							<option value="${sd.sd_cd }">${sd.sd_nm }</option>
						</c:forEach>
				</select>
				
				<button id="chartBtn">검색</button>
			</div>
		<br>
		
		<h3>&nbsp;<i class="fa-solid fa-upload"></i>&nbsp;파일 업로드</h3>
		<button>파일 업로드</button>
	</div>
	
		<div id="map" class="map">
	
		</div>
		
		<!-- 모달 창 -->
		<div id="chartModal" class="modal">
		
    		<div class="modal-content">
        		<h2><i class="fa-solid fa-chart-simple"></i>&nbsp;통계</h2>

	        		<div id="barChart"></div>
	        		
	        		<br>
	        		
	        		<div id="tableChart"></div>
    		
    		</div>
		</div>
	
</body>
</html>