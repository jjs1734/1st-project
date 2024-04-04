package servlet.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import servlet.service.LayerService;

@Service("LayerService")
public class LayerImpl extends EgovAbstractServiceImpl implements LayerService{
	
	@Resource(name="LayerDAO")
	private LayerDAO layerDao;

	@Override
	public List<Map<String, Object>> sd() {
		return layerDao.sd();
	}

	@Override
	public List<Map<String, Object>> sgg(String sd) {
		return layerDao.sgg(sd);
	}

	@Override
	public List<Map<String, Object>> bjd(String sgg) {
		return layerDao.bjd(sgg);
	}

	@Override
	public int ele(String bjdCd) {
		return layerDao.ele(bjdCd);
	}
	
}
