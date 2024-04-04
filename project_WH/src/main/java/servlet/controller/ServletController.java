package servlet.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import servlet.service.ServletService;

@Controller
public class ServletController {
	
	@Autowired
	private ServletService servletService;
	
	@RequestMapping("/test.do")
	public String index() {
		
		return "main/test";
	}
	
}
