package servlet.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import servlet.service.LayerService;

@Controller
public class LayerController {
	
	@Autowired
	private LayerService layerService;
	
	@GetMapping("/main.do")
	public String mapTest(Model model) {
		// 시,도 리스트 생성
		List<Map<String, Object>> sd = layerService.sd();
		System.err.println(sd);
		model.addAttribute("sd", sd);
		return "main/main";
	}
	
	@PostMapping("/getSgg.do")
	@ResponseBody
	public List<Map<String, Object>> getSgg(@RequestParam("sd") String sd) {
		// 이용자가 선택한 시,도 값을 바탕으로 시,군,구 리스트 생성
		List<Map<String, Object>> sgg = layerService.sgg(sd);
		System.out.println(sgg);
		return sgg;
	}
	@PostMapping("/getBjd.do")
	@ResponseBody
	public List<Map<String, Object>> getbjd(@RequestParam("sgg") String sgg) {
		// 이용자가 선택한 시,군,구 값을 바탕으로 법정동 리스트 생성
		List<Map<String, Object>> bjd = layerService.bjd(sgg);
		System.err.println(bjd);
		return bjd;
	}
	
	@PostMapping("/getEle.do")
	@ResponseBody
	public int getElectric(@RequestParam("bjdCd") String bjdCd) {
		System.out.println(bjdCd);
		int ele = layerService.ele(bjdCd);
		System.out.println(ele);
		return ele;
	}
}
