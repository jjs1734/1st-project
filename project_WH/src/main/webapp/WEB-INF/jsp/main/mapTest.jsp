<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>탄소 배출 지도</title>
<script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
<!-- 제이쿼리 -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript">
	
	var sdLayer;
	var sggLayer;
	var bjdLayer;

	$(document).ready(function() {
						$('#sdSelect').change(function() {
											var sdSelectedValue = $(this).val();										// sd_cd
											var sdSelectedText = $(this).find('option:selected').text();				// sd_nm
											var sdExtraInfo = $(this).find('option:selected').data('extra-info');		// extra-info
											var sdExtraInfoArray = sdExtraInfo.split(',');
											var sdCenterValue = sdExtraInfoArray[0];		// sd_geom
											var sdArea = sdExtraInfoArray[1];		// sd_area
											updateAddress(sdSelectedText, null, null); // 상단 주소창에 선택한 시/도 노출
											
											// 기존 레이어가 남아있을 시 모든 레이어 제거
											if(sdLayer || sggLayer || bjdLayer) {
												map.removeLayer(sdLayer);
												map.removeLayer(sggLayer);
												map.removeLayer(bjdLayer);
											}
											
											//geom값 변형
											
											var sdCoordinates = sdCenterValue.match(/POINT\(([\d\.]+) ([\d\.]+)\)/);
											// 좌표값 추출
											var sdX = parseFloat(sdCoordinates[1]); // 경도(Longitude)
											var sdY = parseFloat(sdCoordinates[2]); // 위도(Latitude)
											var sdCenter = ol.proj.fromLonLat([sdX, sdY]);
											
											// 선택한 '시,도'로 줌 및 센터 이동
											map.getView().setCenter(sdCenter);
											if (sdArea > 10000) {
											    map.getView().setZoom(8);
											} else if(sdArea > 5000) {
											    map.getView().setZoom(9);
											} else {
												map.getView().setZoom(10`);
											}
											
											
											sdLayer = new ol.layer.Tile(
													{ // sd 시도
														source : new ol.source.TileWMS(
																{
																	url : 'http://localhost:8080/geoserver/faker/wms?service=WMS', // 1. 레이어 URL
																	params : {
																		'VERSION' : '1.1.0', // 2. 버전
																		'LAYERS' : 'faker:tl_sd', // 3. 작업공간:레이어 명
																		'CQL_FILTER': 'sd_cd=' + sdSelectedValue,
																		'BBOX' : [
																				1.3871489341071218E7,
																				3910407.083927817,
																				1.4680011171788167E7,
																				4666488.829376997 ],
																		'SRS' : 'EPSG:3857', // SRID
																		'FORMAT' : 'image/png' // 포맷
																	},
																	serverType : 'geoserver',
																})
													});
											map.addLayer(sdLayer); // 맵에 레이어를 추가
											
											// ssgSelect, bjdSelect를 초기화
											$('#sggSelect, #bjdSelect').empty().val(null).trigger('change');

											$.ajax({
														type : "POST", //
														url : "/getSgg.do",
														data : { "sido" : sdSelectedText },
														dataType : 'text',
														success : function(
																response) {
															//alert('AJAX 요청 성공!');

															var sgg = JSON.parse(response);

															var sggSelect = $("#sggSelect");
															sggSelect.html("<option>--시/군/구를 선택하세요--</option>");
															for (var i = 0; i < sgg.length; i++) {
																var item = sgg[i];
																sggSelect.append("<option value='" + item.sgg_cd + "' data-extra-info='" + item.sgg_center + "," + item.bjd_area + "'>" + item.sgg_nm + "</option>");
															}
														},
														error : function(xhr, status, error) {
															// 에러 발생 시 수행할 작업
															alert('ajax 실패');
															// console.error("AJAX 요청 실패:", error);
														}
													});
										});

						$('#sggSelect').change(function() {
											var sggSelectedValue = $(this).val();
											
											// 기존 레이어가 남아있을 시 모든 레이어 제거
											if(sggLayer || bjdLayer) {
												
												map.removeLayer(sggLayer);
												map.removeLayer(bjdLayer);
											}
											
											
											if(sggSelectedValue) {
												var sggSelectedText = $(this).find('option:selected').text();
												updateAddress(null, sggSelectedText, null); //상단 시/군/구 노출
												
												var sggExtraInfo = $(this).find('option:selected').data('extra-info');		// extra-info
												var sggExtraInfoArray = sggExtraInfo.split(',');
												var sggCenterValue = sggExtraInfoArray[0];		// sgg_geom
												var sggArea = sggExtraInfoArray[1];		// sgg_area
												
												var sggCoordinates = sggCenterValue.match(/POINT\(([\d\.]+) ([\d\.]+)\)/);
												
												var sggX = parseFloat(sggCoordinates[1]); // 경도(Longitude)
												var sggY = parseFloat(sggCoordinates[2]); // 위도(Latitude)

												var sggCenter = ol.proj.fromLonLat([sggX, sggY]);

												map.getView().setCenter(sggCenter);
												if (sggArea > 1000) {
													map.getView().setZoom(9);
												} else if (sggArea > 500) {
													map.getView().setZoom(10);
												} else {
													map.getView().setZoom(11);
												}
											}
											
											$('#bjdSelect').empty().val(null).trigger('change');
											
											
											
											sggLayer = new ol.layer.Tile(
													{ // sgg 시군구
														source : new ol.source.TileWMS(
																{
																	url : 'http://localhost:8080/geoserver/faker/wms?service=WMS', // 1. 레이어 URL
																	params : {
																		'VERSION' : '1.1.0', // 2. 버전
																		'LAYERS' : 'faker:tl_sgg', // 3. 작업공간:레이어 명
																		'CQL_FILTER': 'sgg_cd=' + sggSelectedValue,
																		'BBOX' : [ 1.386872E7,
																				3906626.5,
																				1.4428071E7,
																				4670269.5 ],
																		'SRS' : 'EPSG:3857', // SRID
																		'FORMAT' : 'image/png' // 포맷
																	},
																	serverType : 'geoserver',
																})
													});

											map.addLayer(sggLayer); // 맵 객체에 레이어를 추가함
											
											$.ajax({
														type : "POST", // 또는 "GET", 요청 방식 선택
														url : "/getBjd.do", // 컨트롤러의 URL 입력
														data : {
															"sgg" : sggSelectedValue
														}, // 선택된 값 전송
														dataType : 'text',
														success : function(
																response) {
															//alert('AJAX 요청 성공!');

															var bjd = JSON.parse(response);

															var bjdSelect = $("#bjdSelect");
															bjdSelect.html("<option>--동/읍/면를 선택하세요--</option>");
															for (var i = 0; i < bjd.length; i++) {
																var item = bjd[i];
																bjdSelect.append("<option value='" + item.bjd_cd + "' data-extra-info='" + item.bjd_center + "," + item.bjd_area + "'>" + item.bjd_nm + "</option>");
															}
														},
														error : function(xhr,status, error) {
															// 에러 발생 시 수행할 작업
															alert('ajax 실패');
															// console.error("AJAX 요청 실패:", error);
														}
													});
										});
						$('#bjdSelect').change(function() {
							var bjdSelectedValue = $(this).val(); // 출력값 bjd_cd
							
							var bjdSelectedText = $(this).find('option:selected').text(); // 출력값 예) OO동
							updateAddress(null, null, bjdSelectedText); //상단 법정동 노출
							
							if(bjdSelectedValue) {
								map.removeLayer(bjdLayer);
								
								var bjdExtraInfo = $(this).find('option:selected').data('extra-info');		// extra-info
								var bjdExtraInfoArray = bjdExtraInfo.split(',');
								var bjdCenterValue = bjdExtraInfoArray[0];		// sgg_geom
								var bjdArea = bjdExtraInfoArray[1];		// sgg_area
								
								var bjdCoordinates = bjdCenterValue.match(/POINT\(([\d\.]+) ([\d\.]+)\)/);
								
								var bjdX = parseFloat(bjdCoordinates[1]); // 경도(Longitude)
								var bjdY = parseFloat(bjdCoordinates[2]); // 위도(Latitude)

								var bjdCenter = ol.proj.fromLonLat([bjdX, bjdY]);
								map.getView().setCenter(bjdCenter);
								if (bjdArea > 100) {
									map.getView().setZoom(12);
								} else if (bjdArea > 5) {
									map.getView().setZoom(13);
								} else {
									map.getView().setZoom(14);
								}
							}
							
							bjdLayer = new ol.layer.Tile(
									{ // bjd 법정동
										source : new ol.source.TileWMS(
												{
													url : 'http://localhost:8080/geoserver/faker/wms?service=WMS', // 1. 레이어 URL
													params : {
														'VERSION' : '1.1.0', // 2. 버전
														'LAYERS' : 'faker:tl_bjd', // 3. 작업공간:레이어 명
														'CQL_FILTER' : 'bjd_cd=' + bjdSelectedValue,
														'BBOX' : [ 1.3873946E7,
																3906626.5,
																1.4428045E7,
																4670269.5 ],
														'SRS' : 'EPSG:3857', // SRID
														'FORMAT' : 'image/png' // 포맷
													},
													serverType : 'geoserver',
												})
									});

							map.addLayer(bjdLayer); // 맵 객체에 레이어를 추가함
							
	//						$.ajax({
	//							type : "POST", //
	//							url : "/getElectric.do", // 컨트롤러의 URL 입력
	//							data : {
	//								"bjd" : bjdSelectedValue
	//							}, // 선택된 값 전송
	//							dataType : 'text',
	//							success : function(response) {
	//								alert('AJAX 요청 성공!');
    //
	//								var bjd = JSON.parse(response);

	//								var bjdSelect = $("#bjdSelect");
									
	//							},
	//							error : function(xhr,status, error) {
									// 에러 발생 시 수행할 작업
	//								alert('ajax 실패');
									// console.error("AJAX 요청 실패:", error);
	//							}
	//						});
							
						});
						
						function updateAddress(sd, sgg, bjd) {
							// 각 select 요소에서 선택된 값 가져오기
					        var sdValue = sd || $('#sdSelect').find('option:selected').text() || '';
					        var sggValue = sgg || $('#sggSelect').find('option:selected').text() || ''; // 선택된 값이 없으면 빈 문자열 나열
					        var bjdValue = bjd || $('#bjdSelect').find('option:selected').text() || '';

					        // 주소 업데이트
					        $('#address').html('<h1>' + sdValue + ' ' + sggValue + ' ' + bjdValue + '</h1>');
						}
						
						let map = new ol.Map(
								{ // OpenLayer의 맵 객체를 생성한다.
									target : 'map', // 맵 객체를 연결하기 위한 target으로 <div>의 id값을 지정해준다.
									layers : [ // 지도에서 사용 할 레이어의 목록을 정의하는 공간이다.
									new ol.layer.Tile(
											{
												source : new ol.source.OSM(
														{
															url : 'https://api.vworld.kr/req/wmts/1.0.0/785143F3-50EE-3760-AF52-103A8D296D30/Base/{z}/{y}/{x}.png' // vworld의 지도를 가져온다.
														})
											}) ],
									view : new ol.View({ // 지도가 보여 줄 중심좌표, 축소, 확대 등을 설정한다. 보통은 줌, 중심좌표를 설정하는 경우가 많다.
										center : ol.proj.fromLonLat([ 128, 36 ]),
										zoom : 8
									})
								});

					});
</script>
<style type="text/css">
.toolBar {
	height: 900px;
	width: 15%;
	float: left;
	background-color: orange;
}
.address {
	height: 50px;
	background-color: aqua;
}
.map {
	height: 850px;
	width: 85%;
	float: right;
}
.footer {
	height: 5%;
	width: 100%;
	clear: both; /* 부모 요소 아래로 내려가도록 함 */
	background-color: gray;
	color: white;
	position: fiexd;
	bottom: 0;
	text-align: center;
}
.selectBar {
	padding: 5px 20px;
	background-color: yellow;
}
.selectBar > select {
	width: 90%;
}
</style>
</head>
<body>
	<div class="main">
		<div class="toolBar">

			<h1>메뉴</h1>
			
			<div class="selectBar">
				<select id="sdSelect">
					<option>--시/도를 선택하세요--</option>
					<c:forEach items="${sido }" var="sido">
						<option value="${sido.sd_cd }" data-extra-info="${sido.sd_center},${sido.sd_area}">${sido.sd_nm }</option>
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
			
		</div>
		
		<div>
		
			<div id="address" class="address">
				<h1>주소창</h1>
			</div>
			
			<div id="map" class="map">
			
			</div>
			
		</div>
		
	</div>
	
	<div class="footer">
	
		<h3>탄소배출량 표기 시스템</h3>
		
	</div>
</body>
</html>