package servlet.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import servlet.service.ChartService;

@Service("ChartService")
public class ChartImpl extends EgovAbstractServiceImpl implements ChartService{
	
	@Resource(name="ChartDAO")
	private ChartDAO chartDao;

	@Override
	public List<Map<String, Object>> sdChartData() {

		return chartDao.sdChartData();
	}

	@Override
	public List<Map<String, Object>> sggChartData(String sd) {
		return chartDao.sggChartData(sd);
	}
}
