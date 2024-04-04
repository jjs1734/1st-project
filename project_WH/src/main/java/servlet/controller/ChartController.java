package servlet.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import servlet.service.ChartService;
import servlet.service.LayerService;

@Controller
public class ChartController {
	
	@Autowired
	private ChartService chartService;
	
	
	@PostMapping("/sdChartData.do")
	@ResponseBody
	public List<Map<String, Object>> sdData() {
		List<Map<String, Object>> sdData = chartService.sdChartData();
		return sdData;
	}

	@PostMapping("/sggChartData.do")
	@ResponseBody
	public List<Map<String, Object>> sggData(@RequestParam("sd") String sd) {
		List<Map<String, Object>> sggData = chartService.sggChartData(sd);
		
		return sggData;
	}
}
