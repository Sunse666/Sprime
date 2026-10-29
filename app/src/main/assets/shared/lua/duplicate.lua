local M = {}

function M.init(env)
    local config = env.engine.schema.config
    env.keep_comment = config:get_bool('translator/keep_comments')
    local delimiter = config:get_string('speller/delimiter')
    if delimiter and #delimiter > 0 and delimiter:sub(1,1) ~= ' ' then
        env.delimiter = delimiter:sub(1,1)
    end
    env.name_space = env.name_space:gsub('^*', '')
    M.style = config:get_string(env.name_space) or '{comment}'
    
    -- 修正拼音的对应字典
    M.corrections = {
        -- 对于同一个拼音 "bu bu"，存储多个修正选项
        ["a a"] = {
            { text = "啊啊", comment = "a a" },
            { text = "阿阿", comment = "a a" },
        },
        ["a a a"] = {
            { text = "啊啊啊", comment = "a a a" },
            { text = "阿阿阿", comment = "a a a" },
        },
        ["a a a a"] = {
            { text = "啊啊啊啊", comment = "a a a a" },
        },
        ["a an"] = {
            { text = "阿安", comment = "a an" },
        },
        ["a ao"] = {
            { text = "阿敖", comment = "a ao" },
        },
        ["a ba ba"] = {
            { text = "阿巴巴", comment = "a ba ba" },
        },
        ["a ba ba ba"] = {
            { text = "阿巴巴巴", comment = "a ba ba ba" },
        },
        ["a bai"] = {
            { text = "阿白", comment = "a bai" },
        },
        ["a ban"] = {
            { text = "阿班", comment = "a ban" },
        },
        ["a bao"] = {
            { text = "阿宝", comment = "a bao" },
            { text = "阿包", comment = "a bao" },
            { text = "阿豹", comment = "a bao" },
            { text = "阿爆", comment = "a bao" },
            { text = "阿保", comment = "a bao" },
            { text = "阿鲍", comment = "a bao" },
        },
        ["a bei"] = {
            { text = "阿贝", comment = "a bei" },
            { text = "阿北", comment = "a bei" },
        },
        ["a bei er"] = {
            { text = "阿贝尔", comment = "a bei er" },
        },
        ["a ben"] = {
            { text = "阿笨", comment = "a ben" },
            { text = "阿本", comment = "a ben" },
            { text = "阿奔", comment = "a ben" },
        },
        ["a bin"] = {
            { text = "阿斌", comment = "a bin" },
            { text = "阿彬", comment = "a bin" },
            { text = "阿宾", comment = "a bin" },
            { text = "阿滨", comment = "a bin" },
        },
        ["a bu"] = {
            { text = "阿布", comment = "a bu" },
            { text = "啊不", comment = "a bu" },
            { text = "阿不", comment = "a bu" },
            { text = "阿卜", comment = "a bu" },
            { text = "阿部", comment = "a bu" },
        },
        ["a bu di"] = {
            { text = "阿布迪", comment = "a bu di" },
        },
        ["a bu shi"] = {
            { text = "啊不是", comment = "a bu shi" },
        },
        ["a dao"] = {
            { text = "阿道", comment = "a dao" },
            { text = "阿刀", comment = "a dao" },
        },
        ["a di"] = {
            { text = "阿迪", comment = "a di" },
            { text = "阿弟", comment = "a di" },
            { text = "阿娣", comment = "a di" },
            { text = "阿地", comment = "a di" },
            { text = "阿滴", comment = "a di" },
        },
        ["a di la"] = {
            { text = "阿迪拉", comment = "a di la" },
        },
        ["a di lai"] = {
            { text = "阿迪莱", comment = "a di lai" },
        },
        ["a di li"] = {
            { text = "阿迪力", comment = "a di li" },
            { text = "阿地力", comment = "a di li" },
        },
        ["a di na"] = {
            { text = "阿迪娜", comment = "a di na" },
        },
        ["a di si"] = {
            { text = "阿迪斯", comment = "a di si" },
        },
        ["a di ti"] = {
            { text = "阿底提", comment = "a di ti" },
        },
        ["a di wang"] = {
            { text = "阿迪王", comment = "a di wang" },
        },
        ["a di xian"] = {
            { text = "阿蒂仙", comment = "a di xian" },
        },
        ["a di zai"] = {
            { text = "阿弟仔", comment = "a di zai" },
        },
        ["a die"] = {
            { text = "阿爹", comment = "a die" },
        },
        ["a diu"] = {
            { text = "阿丢", comment = "a diu" },
        },
        ["a en"] = {
            { text = "啊恩", comment = "a en" },
        },
        ["a fa"] = {
            { text = "阿发", comment = "a fa" },
        },
        ["a fan"] = {
            { text = "阿帆", comment = "a fan" },
            { text = "阿凡", comment = "a fan" },
            { text = "阿范", comment = "a fan" },
        },
        ["a fei"] = {
            { text = "阿飞", comment = "a fei" },
            { text = "阿肥", comment = "a fei" },
            { text = "阿菲", comment = "a fei" },
            { text = "阿翡", comment = "a fei" },
            { text = "阿斐", comment = "a fei" },
        },
        ["a fen"] = {
            { text = "阿芬", comment = "a fen" },
            { text = "阿粉", comment = "a fen" },
        },
        ["a huai"] = {
            { text = "阿怀", comment = "a huai" },
        },
        ["a na di"] = {
            { text = "阿纳迪", comment = "a na di" },
        },
        ["a nan"] = {
            { text = "阿南", comment = "a nan" },
            { text = "阿楠", comment = "a nan" },
            { text = "阿男", comment = "a nan" },
            { text = "阿难", comment = "a nan" },
        },
        ["a nei"] = {
            { text = "阿内", comment = "a nei" },
        },
        ["a nie"] = {
            { text = "啊捏", comment = "a nie" },
        },
        ["a niu"] = {
            { text = "阿牛", comment = "a niu" },
            { text = "阿妞", comment = "a niu" },
        },
        ["a nou"] = {
            { text = "阿耨", comment = "a nou" },
        },
        ["a nuan"] = {
            { text = "阿暖", comment = "a nuan" },
        },
        ["a nuo"] = {
            { text = "阿诺", comment = "a nuo" },
        },
        ["a nuo de"] = {
            { text = "阿诺德", comment = "a nuo de" },
        },
        ["a o"] = {
            { text = "啊哦", comment = "a o" },
        },
        ["a ou"] = {
            { text = "阿偶", comment = "a ou" },
            { text = "阿欧", comment = "a ou" },
        },
        ["a ou a"] = {
            { text = "啊偶啊", comment = "a ou a" },
            { text = "啊偶啊", comment = "a ou a" },
        },
        ["a ri"] = {
            { text = "阿日", comment = "a ri" },
        },
        ["a ta"] = {
            { text = "阿塔", comment = "a ta" },
        },
        ["a tang"] = {
            { text = "阿汤", comment = "a tang" },
            { text = "阿唐", comment = "a tang" },
            { text = "阿糖", comment = "a tang" },
            { text = "阿棠", comment = "a tang" },
        },
        ["a wa"] = {
            { text = "阿瓦", comment = "a wa" },
        },
        ["a wai"] = {
            { text = "阿歪", comment = "a wai" },
        },
        ["a wan"] = {
            { text = "阿万", comment = "a wan" },
            { text = "阿婉", comment = "a wan" },
        },
        ["a wang"] = {
            { text = "阿旺", comment = "a wang" },
            { text = "阿王", comment = "a wang" },
            { text = "阿汪", comment = "a wang" },
            { text = "阿望", comment = "a wang" },
        },
        ["a wei"] = {
            { text = "阿伟", comment = "a wei" },
            { text = "阿威", comment = "a wei" },
            { text = "啊喂", comment = "a wei" },
            { text = "阿维", comment = "a wei" },
            { text = "阿薇", comment = "a wei" },
            { text = "阿魏", comment = "a wei" },
            { text = "阿炜", comment = "a wei" },
            { text = "阿玮", comment = "a wei" },
            { text = "阿微", comment = "a wei" },
            { text = "阿韦", comment = "a wei" },
            { text = "阿卫", comment = "a wei" },
        },
        ["a wen"] = {
            { text = "阿文", comment = "a wen" },
            { text = "阿雯", comment = "a wen" },
            { text = "阿温", comment = "a wen" },
            { text = "阿闻", comment = "a wen" },
        },
        ["a wo"] = {
            { text = "啊我", comment = "a wo" },
        },
        ["a ya"] = {
            { text = "啊呀", comment = "a ya" },
            { text = "阿雅", comment = "a ya" },
            { text = "阿亚", comment = "a ya" },
        },
        ["a ya ya ya"] = {
            { text = "啊呀呀呀", comment = "a ya ya ya" },
        },
        ["a yan"] = {
            { text = "阿燕", comment = "a yan" },
            { text = "阿艳", comment = "a yan" },
            { text = "阿言", comment = "a yan" },
            { text = "阿妍", comment = "a yan" },
            { text = "阿颜", comment = "a yan" },
            { text = "阿炎", comment = "a yan" },
            { text = "阿岩", comment = "a yan" },
            { text = "阿彦", comment = "a yan" },
            { text = "阿严", comment = "a yan" },
        },
        ["a yang"] = {
            { text = "阿阳", comment = "a yang" },
            { text = "阿杨", comment = "a yang" },
            { text = "阿洋", comment = "a yang" },
            { text = "阿羊", comment = "a yang" },
            { text = "阿扬", comment = "a yang" },
        },
        ["a yao"] = {
            { text = "阿瑶", comment = "a yao" },
            { text = "啊要", comment = "a yao" },
            { text = "阿耀", comment = "a yao" },
            { text = "阿尧", comment = "a yao" },
            { text = "阿姚", comment = "a yao" },
        },
        ["a ye"] = {
            { text = "阿爷", comment = "a ye" },
            { text = "阿耶", comment = "a ye" },
            { text = "阿叶", comment = "a ye" },
            { text = "阿也", comment = "a ye" },
            { text = "阿夜", comment = "a ye" },
        },
        ["a yin"] = {
            { text = "阿银", comment = "a yin" },
            { text = "阿音", comment = "a yin" },
            { text = "阿茵", comment = "a yin" },
        },
        ["a yo"] = {
            { text = "啊哟", comment = "a yo" },
        },
        ["a you"] = {
            { text = "阿尤", comment = "a you" },
            { text = "阿有", comment = "a you" },
            { text = "啊呦", comment = "a you" },
            { text = "阿友", comment = "a you" },
            { text = "阿油", comment = "a you" },
            { text = "阿游", comment = "a you" },
            { text = "阿优", comment = "a you" },
        },
        ["a you qi"] = {
            { text = "阿右旗", comment = "a you qi" },
        },
        ["a yuan"] = {
            { text = "阿园", comment = "a yuan" },
            { text = "阿远", comment = "a yuan" },
            { text = "阿源", comment = "a yuan" },
            { text = "阿元", comment = "a yuan" },
            { text = "阿媛", comment = "a yuan" },
            { text = "阿圆", comment = "a yuan" },
            { text = "阿苑", comment = "a yuan" },
            { text = "阿原", comment = "a yuan" },
            { text = "阿袁", comment = "a yuan" },
            { text = "阿渊", comment = "a yuan" },
            { text = "阿鸢", comment = "a yuan" },
            { text = "阿园", comment = "a yuan" },
            { text = "阿远", comment = "a yuan" },
            { text = "阿源", comment = "a yuan" },
            { text = "阿元", comment = "a yuan" },
            { text = "阿媛", comment = "a yuan" },
            { text = "阿圆", comment = "a yuan" },
            { text = "阿苑", comment = "a yuan" },
            { text = "阿原", comment = "a yuan" },
            { text = "阿袁", comment = "a yuan" },
            { text = "阿渊", comment = "a yuan" },
            { text = "阿鸢", comment = "a yuan" },
        },
        ["a yue"] = {
            { text = "阿月", comment = "a yue" },
            { text = "阿越", comment = "a yue" },
            { text = "阿悦", comment = "a yue" },
            { text = "阿岳", comment = "a yue" },
        },
        ["a yun"] = {
            { text = "阿云", comment = "a yun" },
            { text = "阿芸", comment = "a yun" },
            { text = "阿运", comment = "a yun" },
        },
        ["ai a"] = {
            { text = "爱啊", comment = "ai a" },
        },
        ["ai ai ai a"] = {
            { text = "哎哎哎啊", comment = "ai ai ai a" },
        },
        ["ai an"] = {
            { text = "埃安", comment = "ai an" },
        },
        ["ai ang"] = {
            { text = "艾昂", comment = "ai ang" },
        },
        ["ai ao"] = {
            { text = "艾奥", comment = "ai ao" },
        },
        ["ai bai"] = {
            { text = "爱白", comment = "ai bai" },
            { text = "艾拜", comment = "ai bai" },
        },
        ["ai bu"] = {
            { text = "爱步", comment = "ai bu" },
        },
        ["ai bu qi"] = {
            { text = "爱不起", comment = "ai bu qi" },
        },
        ["ai e"] = {
            { text = "挨饿", comment = "ai e" },
        },
        ["ai huai"] = {
            { text = "爱坏", comment = "ai huai" },
        },
        ["ai ne"] = {
            { text = "爱呢", comment = "ai ne" },
        },
        ["ai nv"] = {
            { text = "爱女", comment = "ai nv" },
        },
        ["ai o"] = {
            { text = "爱哦", comment = "ai o" },
        },
        ["ai o ai"] = {
            { text = "爱喔爱", comment = "ai o ai" },
        },
        ["ai ou"] = {
            { text = "艾欧", comment = "ai ou" },
            { text = "爱欧", comment = "ai ou" },
            { text = "艾欧", comment = "ai ou" },
            { text = "爱欧", comment = "ai ou" },
        },
        ["ai ri"] = {
            { text = "艾日", comment = "ai ri" },
        },
        ["ai xu"] = {
            { text = "爱旭", comment = "ai xu" },
            { text = "艾旭", comment = "ai xu" },
        },
        ["ai yu"] = {
            { text = "碍于", comment = "ai yu" },
            { text = "爱与", comment = "ai yu" },
            { text = "爱玉", comment = "ai yu" },
            { text = "爱欲", comment = "ai yu" },
            { text = "爱育", comment = "ai yu" },
            { text = "艾遇", comment = "ai yu" },
            { text = "艾雨", comment = "ai yu" },
            { text = "爱鱼", comment = "ai yu" },
        },
        ["an an"] = {
            { text = "暗暗", comment = "an an" },
            { text = "安安", comment = "an an" },
            { text = "按按", comment = "an an" },
            { text = "桉桉", comment = "an an" },
            { text = "俺俺", comment = "an an" },
            { text = "鞍鞍", comment = "an an" },
        },
        ["an bu"] = {
            { text = "俺不", comment = "an bu" },
            { text = "暗部", comment = "an bu" },
            { text = "安瓿", comment = "an bu" },
            { text = "庵埠", comment = "an bu" },
            { text = "鞍部", comment = "an bu" },
            { text = "安埠", comment = "an bu" },
            { text = "安布", comment = "an bu" },
        },
        ["an di"] = {
            { text = "安迪", comment = "an di" },
            { text = "案底", comment = "an di" },
            { text = "暗帝", comment = "an di" },
            { text = "暗地", comment = "an di" },
            { text = "俺弟", comment = "an di" },
            { text = "俺滴", comment = "an di" },
            { text = "安地", comment = "an di" },
            { text = "岸堤", comment = "an di" },
            { text = "安底", comment = "an di" },
            { text = "安帝", comment = "an di" },
            { text = "安抵", comment = "an di" },
        },
        ["an fei"] = {
            { text = "安飞", comment = "an fei" },
            { text = "安菲", comment = "an fei" },
        },
        ["an huai"] = {
            { text = "安怀", comment = "an huai" },
        },
        ["an ri"] = {
            { text = "按日", comment = "an ri" },
        },
        ["an wo"] = {
            { text = "按我", comment = "an wo" },
            { text = "安沃", comment = "an wo" },
            { text = "安我", comment = "an wo" },
        },
        ["an wo de"] = {
            { text = "按我的", comment = "an wo de" },
        },
        ["an xu"] = {
            { text = "按需", comment = "an xu" },
            { text = "安许", comment = "an xu" },
            { text = "按序", comment = "an xu" },
            { text = "安旭", comment = "an xu" },
        },
        ["an ye"] = {
            { text = "暗夜", comment = "an ye" },
            { text = "俺也", comment = "an ye" },
            { text = "安业", comment = "an ye" },
            { text = "俺爷", comment = "an ye" },
            { text = "桉叶", comment = "an ye" },
            { text = "安爷", comment = "an ye" },
            { text = "安野", comment = "an ye" },
            { text = "安烨", comment = "an ye" },
        },
        ["an yu"] = {
            { text = "安于", comment = "an yu" },
            { text = "暗语", comment = "an yu" },
            { text = "暗喻", comment = "an yu" },
            { text = "按语", comment = "an yu" },
            { text = "安宇", comment = "an yu" },
            { text = "安玉", comment = "an yu" },
            { text = "安雨", comment = "an yu" },
            { text = "安裕", comment = "an yu" },
            { text = "暗域", comment = "an yu" },
        },
        ["ang a"] = {
            { text = "昂啊", comment = "ang a" },
        },
        ["ang ang"] = {
            { text = "昂昂", comment = "ang ang" },
        },
        ["ao"] = {
            { text = "奥", comment = "ao" },
            { text = "熬", comment = "ao" },
            { text = "傲", comment = "ao" },
            { text = "澳", comment = "ao" },
            { text = "凹", comment = "ao" },
            { text = "袄", comment = "ao" },
            { text = "敖", comment = "ao" },
            { text = "嗷", comment = "ao" },
            { text = "坳", comment = "ao" },
            { text = "拗", comment = "ao" },
            { text = "鳌", comment = "ao" },
            { text = "岙", comment = "ao" },
            { text = "獒", comment = "ao" },
            { text = "翱", comment = "ao" },
            { text = "骜", comment = "ao" },
            { text = "懊", comment = "ao" },
            { text = "螯", comment = "ao" },
            { text = "遨", comment = "ao" },
            { text = "媪", comment = "ao" },
            { text = "奡", comment = "ao" },
            { text = "鏊", comment = "ao" },
            { text = "鏖", comment = "ao" },
            { text = "璈", comment = "ao" },
            { text = "廒", comment = "ao" },
            { text = "嶅", comment = "ao" },
            { text = "聱", comment = "ao" },
            { text = "隩", comment = "ao" },
            { text = "圫", comment = "ao" },
        },
        ["ao ai"] = {
            { text = "澳爱", comment = "ao ai" },
        },
        ["ao an"] = {
            { text = "傲岸", comment = "ao an" },
        },
        ["ao ao"] = {
            { text = "嗷嗷", comment = "ao ao" },
            { text = "奥奥", comment = "ao ao" },
            { text = "熬熬", comment = "ao ao" },
            { text = "袄袄", comment = "ao ao" },
            { text = "凹凹", comment = "ao ao" },
        },
        ["ao ao a"] = {
            { text = "嗷嗷啊", comment = "ao ao a" },
        },
        ["ao ao ao a"] = {
            { text = "嗷嗷嗷啊", comment = "ao ao ao a" },
        },
        ["ao bao"] = {
            { text = "敖包", comment = "ao bao" },
            { text = "奥爆", comment = "ao bao" },
            { text = "澳宝", comment = "ao bao" },
            { text = "奥宝", comment = "ao bao" },
            { text = "凹刨", comment = "ao bao" },
        },
        ["ao bing"] = {
            { text = "敖丙", comment = "ao bing" },
        },
        ["ao ci"] = {
            { text = "奥茨", comment = "ao ci" },
            { text = "奥次", comment = "ao ci" },
        },
        ["ao da"] = {
            { text = "澳大", comment = "ao da" },
            { text = "奥达", comment = "ao da" },
            { text = "澳达", comment = "ao da" },
        },
        ["ao dan"] = {
            { text = "奥蛋", comment = "ao dan" },
        },
        ["ao dao"] = {
            { text = "熬到", comment = "ao dao" },
        },
        ["ao de"] = {
            { text = "奥德", comment = "ao de" },
            { text = "熬得", comment = "ao de" },
            { text = "熬的", comment = "ao de" },
            { text = "澳德", comment = "ao de" },
            { text = "奥得", comment = "ao de" },
            { text = "傲德", comment = "ao de" },
        },
        ["ao deng"] = {
            { text = "奥登", comment = "ao deng" },
        },
        ["ao di"] = {
            { text = "奥迪", comment = "ao di" },
            { text = "傲滴", comment = "ao di" },
            { text = "凹底", comment = "ao di" },
            { text = "凹地", comment = "ao di" },
            { text = "奥帝", comment = "ao di" },
        },
        ["ao di er"] = {
            { text = "奥迪尔", comment = "ao di er" },
        },
        ["ao dian"] = {
            { text = "熬点", comment = "ao dian" },
            { text = "凹点", comment = "ao dian" },
        },
        ["ao ding"] = {
            { text = "奥丁", comment = "ao ding" },
        },
        ["ao du"] = {
            { text = "奥都", comment = "ao du" },
            { text = "奥杜", comment = "ao du" },
            { text = "澳都", comment = "ao du" },
        },
        ["ao en"] = {
            { text = "奥恩", comment = "ao en" },
        },
        ["ao er"] = {
            { text = "奥尔", comment = "ao er" },
        },
        ["ao fa"] = {
            { text = "奥法", comment = "ao fa" },
            { text = "奥发", comment = "ao fa" },
        },
        ["ao gang"] = {
            { text = "奥港", comment = "ao gang" },
        },
        ["ao ge"] = {
            { text = "奥格", comment = "ao ge" },
            { text = "熬个", comment = "ao ge" },
            { text = "奥哥", comment = "ao ge" },
            { text = "傲哥", comment = "ao ge" },
            { text = "敖哥", comment = "ao ge" },
            { text = "澳哥", comment = "ao ge" },
        },
        ["ao gu"] = {
            { text = "傲骨", comment = "ao gu" },
            { text = "奥古", comment = "ao gu" },
        },
        ["ao guang"] = {
            { text = "敖广", comment = "ao guang" },
            { text = "奥光", comment = "ao guang" },
        },
        ["ao guo"] = {
            { text = "熬过", comment = "ao guo" },
        },
        ["ao hai"] = {
            { text = "奥海", comment = "ao hai" },
            { text = "澳海", comment = "ao hai" },
        },
        ["ao hang"] = {
            { text = "澳航", comment = "ao hang" },
            { text = "傲航", comment = "ao hang" },
        },
        ["ao hao"] = {
            { text = "熬好", comment = "ao hao" },
            { text = "嗷嚎", comment = "ao hao" },
        },
        ["ao hua"] = {
            { text = "奥华", comment = "ao hua" },
            { text = "澳华", comment = "ao hua" },
            { text = "傲华", comment = "ao hua" },
        },
        ["ao huai"] = {
            { text = "熬坏", comment = "ao huai" },
        },
        ["ao ji"] = {
            { text = "澳际", comment = "ao ji" },
            { text = "傲基", comment = "ao ji" },
            { text = "奥吉", comment = "ao ji" },
        },
        ["ao jia"] = {
            { text = "澳甲", comment = "ao jia" },
            { text = "奥佳", comment = "ao jia" },
            { text = "奥加", comment = "ao jia" },
            { text = "奥嘉", comment = "ao jia" },
            { text = "澳加", comment = "ao jia" },
            { text = "奥伽", comment = "ao jia" },
            { text = "澳佳", comment = "ao jia" },
            { text = "奥家", comment = "ao jia" },
        },
        ["ao jian"] = {
            { text = "傲剑", comment = "ao jian" },
            { text = "熬煎", comment = "ao jian" },
        },
        ["ao jiang"] = {
            { text = "鳌江", comment = "ao jiang" },
            { text = "敖江", comment = "ao jiang" },
        },
        ["ao jiao"] = {
            { text = "傲娇", comment = "ao jiao" },
            { text = "熬胶", comment = "ao jiao" },
        },
        ["ao jing"] = {
            { text = "澳景", comment = "ao jing" },
            { text = "凹镜", comment = "ao jing" },
            { text = "奥精", comment = "ao jing" },
            { text = "奥晶", comment = "ao jing" },
        },
        ["ao ju"] = {
            { text = "傲居", comment = "ao ju" },
            { text = "澳桔", comment = "ao ju" },
        },
        ["ao kai"] = {
            { text = "奥凯", comment = "ao kai" },
        },
        ["ao kan"] = {
            { text = "奥坎", comment = "ao kan" },
        },
        ["ao ke"] = {
            { text = "澳客", comment = "ao ke" },
            { text = "奥克", comment = "ao ke" },
            { text = "奥科", comment = "ao ke" },
            { text = "澳科", comment = "ao ke" },
        },
        ["ao le"] = {
            { text = "熬了", comment = "ao le" },
            { text = "奥乐", comment = "ao le" },
            { text = "澳乐", comment = "ao le" },
        },
        ["ao li"] = {
            { text = "奥利", comment = "ao li" },
            { text = "奥力", comment = "ao li" },
            { text = "奥莉", comment = "ao li" },
            { text = "傲立", comment = "ao li" },
            { text = "奥立", comment = "ao li" },
            { text = "奥丽", comment = "ao li" },
            { text = "澳利", comment = "ao li" },
            { text = "奥里", comment = "ao li" },
            { text = "傲丽", comment = "ao li" },
            { text = "澳丽", comment = "ao li" },
        },
        ["ao ling"] = {
            { text = "奥铃", comment = "ao ling" },
            { text = "奥菱", comment = "ao ling" },
        },
        ["ao lun"] = {
            { text = "奥伦", comment = "ao lun" },
        },
        ["ao luo"] = {
            { text = "奥罗", comment = "ao luo" },
            { text = "奥洛", comment = "ao luo" },
        },
        ["ao men"] = {
            { text = "澳门", comment = "ao men" },
        },
        ["ao mian"] = {
            { text = "凹面", comment = "ao mian" },
            { text = "澳棉", comment = "ao mian" },
        },
        ["ao mo"] = {
            { text = "奥摩", comment = "ao mo" },
            { text = "熬磨", comment = "ao mo" },
            { text = "鏖魔", comment = "ao mo" },
        },
        ["ao mu"] = {
            { text = "凹模", comment = "ao mu" },
            { text = "澳牧", comment = "ao mu" },
            { text = "奥姆", comment = "ao mu" },
        },
        ["ao na"] = {
            { text = "奥纳", comment = "ao na" },
        },
        ["ao pai"] = {
            { text = "奥派", comment = "ao pai" },
            { text = "傲湃", comment = "ao pai" },
        },
        ["ao ping"] = {
            { text = "敖平", comment = "ao ping" },
        },
        ["ao qi"] = {
            { text = "奥奇", comment = "ao qi" },
            { text = "傲气", comment = "ao qi" },
            { text = "奥琪", comment = "ao qi" },
            { text = "奥淇", comment = "ao qi" },
            { text = "奥旗", comment = "ao qi" },
        },
        ["ao qian"] = {
            { text = "澳前", comment = "ao qian" },
        },
        ["ao qu"] = {
            { text = "奥曲", comment = "ao qu" },
        },
        ["ao ri"] = {
            { text = "奥日", comment = "ao ri" },
        },
        ["ao sha"] = {
            { text = "奥沙", comment = "ao sha" },
        },
        ["ao shan"] = {
            { text = "奥山", comment = "ao shan" },
            { text = "鳌山", comment = "ao shan" },
            { text = "岙山", comment = "ao shan" },
        },
        ["ao shang"] = {
            { text = "熬上", comment = "ao shang" },
            { text = "坳上", comment = "ao shang" },
            { text = "奥尚", comment = "ao shang" },
        },
        ["ao shen"] = {
            { text = "奥神", comment = "ao shen" },
            { text = "奥深", comment = "ao shen" },
            { text = "奥申", comment = "ao shen" },
        },
        ["ao shi"] = {
            { text = "傲视", comment = "ao shi" },
            { text = "傲世", comment = "ao shi" },
            { text = "奥世", comment = "ao shi" },
            { text = "澳式", comment = "ao shi" },
            { text = "奥氏", comment = "ao shi" },
            { text = "奥仕", comment = "ao shi" },
            { text = "奥式", comment = "ao shi" },
        },
        ["ao shou"] = {
            { text = "奥兽", comment = "ao shou" },
        },
        ["ao si"] = {
            { text = "奥斯", comment = "ao si" },
            { text = "熬死", comment = "ao si" },
            { text = "澳斯", comment = "ao si" },
            { text = "奥丝", comment = "ao si" },
        },
        ["ao si te"] = {
            { text = "奥斯特", comment = "ao si te" },
            { text = "澳斯特", comment = "ao si te" },
        },
        ["ao su"] = {
            { text = "奥苏", comment = "ao su" },
        },
        ["ao ta"] = {
            { text = "奥塔", comment = "ao ta" },
        },
        ["ao tai"] = {
            { text = "奥泰", comment = "ao tai" },
            { text = "奥太", comment = "ao tai" },
            { text = "澳泰", comment = "ao tai" },
        },
        ["ao tan"] = {
            { text = "奥坦", comment = "ao tan" },
        },
        ["ao tang"] = {
            { text = "熬汤", comment = "ao tang" },
        },
        ["ao tou"] = {
            { text = "鳌头", comment = "ao tou" },
            { text = "澳头", comment = "ao tou" },
            { text = "坳头", comment = "ao tou" },
        },
        ["ao tu"] = {
            { text = "凹凸", comment = "ao tu" },
            { text = "奥图", comment = "ao tu" },
        },
        ["ao tuo"] = {
            { text = "奥拓", comment = "ao tuo" },
            { text = "奥托", comment = "ao tuo" },
        },
        ["ao wa"] = {
            { text = "奥瓦", comment = "ao wa" },
        },
        ["ao wei"] = {
            { text = "奥维", comment = "ao wei" },
            { text = "奥威", comment = "ao wei" },
            { text = "傲威", comment = "ao wei" },
            { text = "澳维", comment = "ao wei" },
            { text = "澳威", comment = "ao wei" },
            { text = "奥伟", comment = "ao wei" },
        },
        ["ao xi"] = {
            { text = "奥西", comment = "ao xi" },
        },
        ["ao xiang"] = {
            { text = "翱翔", comment = "ao xiang" },
            { text = "奥翔", comment = "ao xiang" },
            { text = "敖翔", comment = "ao xiang" },
            { text = "奥祥", comment = "ao xiang" },
            { text = "澳翔", comment = "ao xiang" },
            { text = "傲翔", comment = "ao xiang" },
        },
        ["ao xiao"] = {
            { text = "傲笑", comment = "ao xiao" },
        },
        ["ao xie"] = {
            { text = "奥谢", comment = "ao xie" },
            { text = "傲血", comment = "ao xie" },
        },
        ["ao xin"] = {
            { text = "澳新", comment = "ao xin" },
            { text = "熬心", comment = "ao xin" },
            { text = "奥新", comment = "ao xin" },
            { text = "奥鑫", comment = "ao xin" },
            { text = "奥信", comment = "ao xin" },
            { text = "澳鑫", comment = "ao xin" },
            { text = "澳信", comment = "ao xin" },
            { text = "奥欣", comment = "ao xin" },
        },
        ["ao xing"] = {
            { text = "奥星", comment = "ao xing" },
            { text = "熬兴", comment = "ao xing" },
            { text = "澳星", comment = "ao xing" },
            { text = "奥兴", comment = "ao xing" },
            { text = "敖兴", comment = "ao xing" },
        },
        ["ao xiu"] = {
            { text = "奥修", comment = "ao xiu" },
        },
        ["ao xue"] = {
            { text = "傲雪", comment = "ao xue" },
            { text = "傲血", comment = "ao xue" },
            { text = "奥雪", comment = "ao xue" },
            { text = "澳雪", comment = "ao xue" },
        },
        ["ao ya"] = {
            { text = "奥雅", comment = "ao ya" },
            { text = "奥亚", comment = "ao ya" },
            { text = "澳亚", comment = "ao ya" },
        },
        ["ao yan"] = {
            { text = "敖燕", comment = "ao yan" },
        },
        ["ao ye"] = {
            { text = "熬夜", comment = "ao ye" },
            { text = "奥耶", comment = "ao ye" },
            { text = "奥野", comment = "ao ye" },
        },
        ["ao yin"] = {
            { text = "凹印", comment = "ao yin" },
            { text = "澳银", comment = "ao yin" },
            { text = "凹音", comment = "ao yin" },
            { text = "拗音", comment = "ao yin" },
        },
        ["ao you"] = {
            { text = "遨游", comment = "ao you" },
            { text = "澳优", comment = "ao you" },
            { text = "傲游", comment = "ao you" },
            { text = "澳邮", comment = "ao you" },
            { text = "奥友", comment = "ao you" },
            { text = "奥优", comment = "ao you" },
        },
        ["ao yu"] = {
            { text = "奥宇", comment = "ao yu" },
            { text = "傲宇", comment = "ao yu" },
            { text = "鳌鱼", comment = "ao yu" },
            { text = "奥语", comment = "ao yu" },
            { text = "澳宇", comment = "ao yu" },
        },
        ["ao yuan"] = {
            { text = "奥园", comment = "ao yuan" },
            { text = "澳元", comment = "ao yuan" },
            { text = "奥源", comment = "ao yuan" },
            { text = "澳源", comment = "ao yuan" },
            { text = "獒园", comment = "ao yuan" },
            { text = "奥援", comment = "ao yuan" },
        },
        ["ao yue"] = {
            { text = "傲月", comment = "ao yue" },
            { text = "奥悦", comment = "ao yue" },
            { text = "奥越", comment = "ao yue" },
        },
        ["ao zhao"] = {
            { text = "敖钊", comment = "ao zhao" },
        },
        ["ao zhi"] = {
            { text = "熬制", comment = "ao zhi" },
            { text = "奥旨", comment = "ao zhi" },
        },
        ["ao zhong"] = {
            { text = "奥众", comment = "ao zhong" },
            { text = "澳中", comment = "ao zhong" },
            { text = "鳌中", comment = "ao zhong" },
        },
        ["ao zhou"] = {
            { text = "澳洲", comment = "ao zhou" },
            { text = "熬粥", comment = "ao zhou" },
        },
        ["ao zhu"] = {
            { text = "熬煮", comment = "ao zhu" },
        },
        ["ao zi"] = {
            { text = "袄子", comment = "ao zi" },
            { text = "奥兹", comment = "ao zi" },
            { text = "鏊子", comment = "ao zi" },
            { text = "傲滋", comment = "ao zi" },
        },
        ["ba"] = {
            { text = "把", comment = "ba" },
            { text = "吧", comment = "ba" },
            { text = "八", comment = "ba" },
            { text = "爸", comment = "ba" },
            { text = "巴", comment = "ba" },
            { text = "拔", comment = "ba" },
            { text = "罢", comment = "ba" },
            { text = "霸", comment = "ba" },
            { text = "扒", comment = "ba" },
            { text = "捌", comment = "ba" },
            { text = "坝", comment = "ba" },
            { text = "疤", comment = "ba" },
            { text = "靶", comment = "ba" },
            { text = "芭", comment = "ba" },
            { text = "叭", comment = "ba" },
            { text = "粑", comment = "ba" },
            { text = "耙", comment = "ba" },
            { text = "钯", comment = "ba" },
            { text = "跋", comment = "ba" },
            { text = "笆", comment = "ba" },
            { text = "灞", comment = "ba" },
            { text = "鲅", comment = "ba" },
            { text = "岜", comment = "ba" },
            { text = "魃", comment = "ba" },
            { text = "菝", comment = "ba" },
            { text = "鲃", comment = "ba" },
            { text = "茇", comment = "ba" },
            { text = "朳", comment = "ba" },
            { text = "妭", comment = "ba" },
            { text = "羓", comment = "ba" },
            { text = "胈", comment = "ba" },
            { text = "鲌", comment = "ba" },
            { text = "蚆", comment = "ba" },
        },
        ["ba ba"] = {
            { text = "爸爸", comment = "ba ba" },
            { text = "粑粑", comment = "ba ba" },
            { text = "把把", comment = "ba ba" },
            { text = "巴巴", comment = "ba ba" },
            { text = "叭叭", comment = "ba ba" },
            { text = "霸霸", comment = "ba ba" },
            { text = "八八", comment = "ba ba" },
            { text = "芭芭", comment = "ba ba" },
            { text = "坝坝", comment = "ba ba" },
            { text = "拔拔", comment = "ba ba" },
            { text = "扒扒", comment = "ba ba" },
            { text = "吧吧", comment = "ba ba" },
            { text = "峇峇", comment = "ba ba" },
        },
        ["ba bai"] = {
            { text = "八百", comment = "ba bai" },
            { text = "捌佰", comment = "ba bai" },
            { text = "八佰", comment = "ba bai" },
        },
        ["ba ban"] = {
            { text = "八班", comment = "ba ban" },
            { text = "靶板", comment = "ba ban" },
            { text = "扒板", comment = "ba ban" },
        },
        ["ba bang"] = {
            { text = "霸榜", comment = "ba bang" },
        },
        ["ba bao"] = {
            { text = "八宝", comment = "ba bao" },
            { text = "八堡", comment = "ba bao" },
            { text = "巴宝", comment = "ba bao" },
        },
        ["ba bei"] = {
            { text = "八倍", comment = "ba bei" },
            { text = "巴贝", comment = "ba bei" },
        },
        ["ba ben"] = {
            { text = "八本", comment = "ba ben" },
        },
        ["ba bie"] = {
            { text = "巴别", comment = "ba bie" },
        },
        ["ba bu"] = {
            { text = "八部", comment = "ba bu" },
            { text = "八步", comment = "ba bu" },
            { text = "巴布", comment = "ba bu" },
            { text = "八布", comment = "ba bu" },
        },
        ["ba na"] = {
            { text = "把那", comment = "ba na" },
        },
        ["ba nan"] = {
            { text = "巴南", comment = "ba nan" },
        },
        ["ba nan qu"] = {
            { text = "巴南区", comment = "ba nan qu" },
        },
        ["ba nei"] = {
            { text = "吧内", comment = "ba nei" },
        },
        ["ba nin"] = {
            { text = "把您", comment = "ba nin" },
        },
        ["ba niu"] = {
            { text = "把牛", comment = "ba niu" },
        },
        ["ba nuo"] = {
            { text = "巴诺", comment = "ba nuo" },
        },
        ["ba ou"] = {
            { text = "巴欧", comment = "ba ou" },
            { text = "芭欧", comment = "ba ou" },
        },
        ["ba tan"] = {
            { text = "八滩", comment = "ba tan" },
            { text = "钯碳", comment = "ba tan" },
        },
        ["ba te"] = {
            { text = "巴特", comment = "ba te" },
        },
        ["ba tie"] = {
            { text = "巴铁", comment = "ba tie" },
        },
        ["ba tou"] = {
            { text = "把头", comment = "ba tou" },
            { text = "坝头", comment = "ba tou" },
            { text = "巴头", comment = "ba tou" },
        },
        ["ba tuan"] = {
            { text = "八团", comment = "ba tuan" },
        },
        ["ba tuo"] = {
            { text = "巴托", comment = "ba tuo" },
        },
        ["ba ya"] = {
            { text = "拔牙", comment = "ba ya" },
            { text = "巴亚", comment = "ba ya" },
        },
        ["ba yan"] = {
            { text = "巴彦", comment = "ba yan" },
            { text = "罢演", comment = "ba yan" },
            { text = "把烟", comment = "ba yan" },
            { text = "巴燕", comment = "ba yan" },
        },
        ["ba yang"] = {
            { text = "八样", comment = "ba yang" },
            { text = "巴阳", comment = "ba yang" },
        },
        ["ba yao"] = {
            { text = "把药", comment = "ba yao" },
            { text = "八要", comment = "ba yao" },
        },
        ["ba ye"] = {
            { text = "霸业", comment = "ba ye" },
            { text = "八爷", comment = "ba ye" },
            { text = "八冶", comment = "ba ye" },
            { text = "巴爷", comment = "ba ye" },
        },
        ["ba yin"] = {
            { text = "八音", comment = "ba yin" },
            { text = "巴音", comment = "ba yin" },
            { text = "拔印", comment = "ba yin" },
        },
        ["ba yin zhen"] = {
            { text = "巴音镇", comment = "ba yin zhen" },
        },
        ["ba you"] = {
            { text = "吧友", comment = "ba you" },
            { text = "把油", comment = "ba you" },
        },
        ["ba yuan"] = {
            { text = "八元", comment = "ba yuan" },
            { text = "捌元", comment = "ba yuan" },
            { text = "八院", comment = "ba yuan" },
            { text = "吧员", comment = "ba yuan" },
            { text = "八元", comment = "ba yuan" },
            { text = "捌元", comment = "ba yuan" },
            { text = "八院", comment = "ba yuan" },
            { text = "吧员", comment = "ba yuan" },
        },
        ["bai a"] = {
            { text = "百阿", comment = "bai a" },
        },
        ["bai an"] = {
            { text = "白案", comment = "bai an" },
            { text = "百安", comment = "bai an" },
            { text = "白安", comment = "bai an" },
            { text = "柏安", comment = "bai an" },
        },
        ["bai ang"] = {
            { text = "白昂", comment = "bai ang" },
            { text = "柏昂", comment = "bai ang" },
        },
        ["bai ao"] = {
            { text = "百奥", comment = "bai ao" },
            { text = "拜奥", comment = "bai ao" },
            { text = "百傲", comment = "bai ao" },
            { text = "佰奥", comment = "bai ao" },
            { text = "百澳", comment = "bai ao" },
        },
        ["bai bu"] = {
            { text = "百步", comment = "bai bu" },
            { text = "白布", comment = "bai bu" },
            { text = "摆布", comment = "bai bu" },
            { text = "百部", comment = "bai bu" },
            { text = "白部", comment = "bai bu" },
            { text = "白埠", comment = "bai bu" },
            { text = "白醭", comment = "bai bu" },
        },
        ["bai du ban"] = {
            { text = "百度版", comment = "bai du ban" },
        },
        ["bai duo an"] = {
            { text = "百多安", comment = "bai duo an" },
        },
        ["bai e"] = {
            { text = "白鹅", comment = "bai e" },
            { text = "白俄", comment = "bai e" },
            { text = "拜厄", comment = "bai e" },
            { text = "白垩", comment = "bai e" },
            { text = "白蛾", comment = "bai e" },
            { text = "白哦", comment = "bai e" },
        },
        ["bai fo"] = {
            { text = "拜佛", comment = "bai fo" },
            { text = "白佛", comment = "bai fo" },
        },
        ["bai hua bu"] = {
            { text = "百花布", comment = "bai hua bu" },
        },
        ["bai huai"] = {
            { text = "败坏", comment = "bai huai" },
        },
        ["bai ou"] = {
            { text = "白鸥", comment = "bai ou" },
            { text = "拜欧", comment = "bai ou" },
            { text = "佰欧", comment = "bai ou" },
            { text = "白鸥", comment = "bai ou" },
            { text = "拜欧", comment = "bai ou" },
            { text = "佰欧", comment = "bai ou" },
        },
        ["bai ri"] = {
            { text = "百日", comment = "bai ri" },
            { text = "白日", comment = "bai ri" },
            { text = "拜日", comment = "bai ri" },
        },
        ["bai rou"] = {
            { text = "白肉", comment = "bai rou" },
        },
        ["bai xi niu"] = {
            { text = "白犀牛", comment = "bai xi niu" },
        },
        ["bai xin yu"] = {
            { text = "白新宇", comment = "bai xin yu" },
        },
        ["bai xu"] = {
            { text = "败絮", comment = "bai xu" },
            { text = "白旭", comment = "bai xu" },
            { text = "白圩", comment = "bai xu" },
        },
        ["bai yu"] = {
            { text = "白玉", comment = "bai yu" },
            { text = "白宇", comment = "bai yu" },
            { text = "白羽", comment = "bai yu" },
            { text = "白鱼", comment = "bai yu" },
            { text = "百余", comment = "bai yu" },
            { text = "白雨", comment = "bai yu" },
            { text = "白钰", comment = "bai yu" },
            { text = "百裕", comment = "bai yu" },
            { text = "白瑜", comment = "bai yu" },
            { text = "百誉", comment = "bai yu" },
            { text = "百育", comment = "bai yu" },
            { text = "白煜", comment = "bai yu" },
        },
        ["bai yu zhen"] = {
            { text = "白玉珍", comment = "bai yu zhen" },
        },
        ["ban"] = {
            { text = "办", comment = "ban" },
            { text = "半", comment = "ban" },
            { text = "班", comment = "ban" },
            { text = "版", comment = "ban" },
            { text = "搬", comment = "ban" },
            { text = "般", comment = "ban" },
            { text = "板", comment = "ban" },
            { text = "伴", comment = "ban" },
            { text = "拌", comment = "ban" },
            { text = "扮", comment = "ban" },
            { text = "斑", comment = "ban" },
            { text = "瓣", comment = "ban" },
            { text = "扳", comment = "ban" },
            { text = "绊", comment = "ban" },
            { text = "坂", comment = "ban" },
            { text = "颁", comment = "ban" },
            { text = "阪", comment = "ban" },
            { text = "钣", comment = "ban" },
            { text = "癍", comment = "ban" },
            { text = "湴", comment = "ban" },
            { text = "舨", comment = "ban" },
            { text = "瘢", comment = "ban" },
            { text = "昄", comment = "ban" },
            { text = "柈", comment = "ban" },
            { text = "靽", comment = "ban" },
            { text = "攽", comment = "ban" },
            { text = "𨭉", comment = "ban" },
        },
        ["ban a"] = {
            { text = "办啊", comment = "ban a" },
        },
        ["ban an"] = {
            { text = "办案", comment = "ban an" },
        },
        ["ban an qu"] = {
            { text = "办案区", comment = "ban an qu" },
        },
        ["ban ao"] = {
            { text = "办奥", comment = "ban ao" },
        },
        ["ban di"] = {
            { text = "板底", comment = "ban di" },
            { text = "班底", comment = "ban di" },
            { text = "班迪", comment = "ban di" },
            { text = "半堤", comment = "ban di" },
        },
        ["ban fo"] = {
            { text = "半佛", comment = "ban fo" },
        },
        ["ban wo"] = {
            { text = "伴我", comment = "ban wo" },
        },
        ["ban yu"] = {
            { text = "伴鱼", comment = "ban yu" },
            { text = "斑鱼", comment = "ban yu" },
            { text = "伴鱼", comment = "ban yu" },
            { text = "斑鱼", comment = "ban yu" },
        },
        ["bang an"] = {
            { text = "帮俺", comment = "bang an" },
        },
        ["bang bu"] = {
            { text = "帮补", comment = "bang bu" },
            { text = "帮不", comment = "bang bu" },
            { text = "帮部", comment = "bang bu" },
            { text = "磅布", comment = "bang bu" },
        },
        ["bang e"] = {
            { text = "榜额", comment = "bang e" },
        },
        ["bang ou"] = {
            { text = "帮偶", comment = "bang ou" },
        },
        ["bang wo"] = {
            { text = "帮我", comment = "bang wo" },
            { text = "绑我", comment = "bang wo" },
        },
        ["bang xu"] = {
            { text = "榜圩", comment = "bang xu" },
        },
        ["bang ye"] = {
            { text = "邦业", comment = "bang ye" },
        },
        ["bao a"] = {
            { text = "报啊", comment = "bao a" },
        },
        ["bao ai"] = {
            { text = "葆艾", comment = "bao ai" },
        },
        ["bao an"] = {
            { text = "保安", comment = "bao an" },
            { text = "宝安", comment = "bao an" },
            { text = "报案", comment = "bao an" },
            { text = "包案", comment = "bao an" },
        },
        ["bao ang"] = {
            { text = "包昂", comment = "bao ang" },
        },
        ["bao di"] = {
            { text = "保底", comment = "bao di" },
            { text = "宝坻", comment = "bao di" },
            { text = "宝地", comment = "bao di" },
            { text = "宝迪", comment = "bao di" },
            { text = "胞弟", comment = "bao di" },
            { text = "包地", comment = "bao di" },
            { text = "包底", comment = "bao di" },
            { text = "宝弟", comment = "bao di" },
            { text = "宝帝", comment = "bao di" },
            { text = "包弟", comment = "bao di" },
            { text = "鲍迪", comment = "bao di" },
        },
        ["bao en"] = {
            { text = "报恩", comment = "bao en" },
            { text = "宝恩", comment = "bao en" },
        },
        ["bao fo"] = {
            { text = "抱佛", comment = "bao fo" },
        },
        ["bao li wei"] = {
            { text = "保利威", comment = "bao li wei" },
        },
        ["bao liu di"] = {
            { text = "保留地", comment = "bao liu di" },
        },
        ["bao ye"] = {
            { text = "包夜", comment = "bao ye" },
            { text = "报业", comment = "bao ye" },
            { text = "宝业", comment = "bao ye" },
            { text = "宝冶", comment = "bao ye" },
            { text = "宝爷", comment = "bao ye" },
            { text = "宝烨", comment = "bao ye" },
        },
        ["bao zha tou"] = {
            { text = "爆炸头", comment = "bao zha tou" },
        },
        ["bao zhang bu"] = {
            { text = "保障部", comment = "bao zhang bu" },
        },
        ["bei bu"] = {
            { text = "背部", comment = "bei bu" },
            { text = "北部", comment = "bei bu" },
            { text = "被捕", comment = "bei bu" },
            { text = "备布", comment = "bei bu" },
            { text = "北埔", comment = "bei bu" },
            { text = "北堡", comment = "bei bu" },
        },
        ["bei bu ren"] = {
            { text = "北埔人", comment = "bei bu ren" },
        },
        ["bei da ban"] = {
            { text = "北大班", comment = "bei da ban" },
        },
        ["bei dao an"] = {
            { text = "被盗案", comment = "bei dao an" },
        },
        ["bei ou"] = {
            { text = "北欧", comment = "bei ou" },
        },
        ["bei ou ren"] = {
            { text = "北欧人", comment = "bei ou ren" },
        },
        ["bi a"] = {
            { text = "比啊", comment = "bi a" },
        },
        ["bi bu"] = {
            { text = "壁布", comment = "bi bu" },
            { text = "比不", comment = "bi bu" },
            { text = "鼻部", comment = "bi bu" },
        },
        ["bi bu qi"] = {
            { text = "比不起", comment = "bi bu qi" },
        },
        ["bi da"] = {
            { text = "必答", comment = "bi da" },
            { text = "必达", comment = "bi da" },
            { text = "必打", comment = "bi da" },
            { text = "笔答", comment = "bi da" },
            { text = "壁达", comment = "bi da" },
        },
        ["bi dai"] = {
            { text = "笔袋", comment = "bi dai" },
            { text = "必带", comment = "bi dai" },
            { text = "臂带", comment = "bi dai" },
        },
        ["bi dan"] = {
            { text = "逼单", comment = "bi dan" },
            { text = "碧丹", comment = "bi dan" },
        },
        ["bi dao"] = {
            { text = "逼到", comment = "bi dao" },
            { text = "必到", comment = "bi dao" },
            { text = "毕导", comment = "bi dao" },
            { text = "比到", comment = "bi dao" },
            { text = "碧道", comment = "bi dao" },
            { text = "笔刀", comment = "bi dao" },
        },
        ["bi de"] = {
            { text = "逼得", comment = "bi de" },
            { text = "比的", comment = "bi de" },
            { text = "逼的", comment = "bi de" },
            { text = "彼得", comment = "bi de" },
            { text = "必得", comment = "bi de" },
            { text = "比德", comment = "bi de" },
            { text = "毕得", comment = "bi de" },
            { text = "彼德", comment = "bi de" },
        },
        ["bi die"] = {
            { text = "必跌", comment = "bi die" },
        },
        ["bi diu"] = {
            { text = "比丢", comment = "bi diu" },
        },
        ["bi dou"] = {
            { text = "鼻窦", comment = "bi dou" },
            { text = "比斗", comment = "bi dou" },
        },
        ["bi duan"] = {
            { text = "弊端", comment = "bi duan" },
            { text = "笔端", comment = "bi duan" },
            { text = "彼端", comment = "bi duan" },
            { text = "鼻端", comment = "bi duan" },
        },
        ["bi duo"] = {
            { text = "比多", comment = "bi duo" },
        },
        ["bi nan"] = {
            { text = "避难", comment = "bi nan" },
        },
        ["bi nin"] = {
            { text = "比您", comment = "bi nin" },
        },
        ["bi niu"] = {
            { text = "鼻牛", comment = "bi niu" },
        },
        ["bi ou"] = {
            { text = "比偶", comment = "bi ou" },
            { text = "碧藕", comment = "bi ou" },
            { text = "彼欧", comment = "bi ou" },
            { text = "比欧", comment = "bi ou" },
        },
        ["bi ou qi"] = {
            { text = "碧欧奇", comment = "bi ou qi" },
        },
        ["bi ta"] = {
            { text = "比他", comment = "bi ta" },
            { text = "比她", comment = "bi ta" },
            { text = "逼她", comment = "bi ta" },
            { text = "逼他", comment = "bi ta" },
            { text = "比它", comment = "bi ta" },
        },
        ["bi tan"] = {
            { text = "笔谈", comment = "bi tan" },
            { text = "碧潭", comment = "bi tan" },
            { text = "壁毯", comment = "bi tan" },
        },
        ["bi tie"] = {
            { text = "鼻贴", comment = "bi tie" },
            { text = "臂贴", comment = "bi tie" },
        },
        ["bi tou"] = {
            { text = "鼻头", comment = "bi tou" },
            { text = "笔头", comment = "bi tou" },
            { text = "碧头", comment = "bi tou" },
        },
        ["bi tuan"] = {
            { text = "逼团", comment = "bi tuan" },
        },
        ["bian huai"] = {
            { text = "变坏", comment = "bian huai" },
        },
        ["bian ri"] = {
            { text = "辩日", comment = "bian ri" },
        },
        ["bie"] = {
            { text = "别", comment = "bie" },
            { text = "憋", comment = "bie" },
            { text = "瘪", comment = "bie" },
            { text = "鳖", comment = "bie" },
            { text = "蹩", comment = "bie" },
            { text = "癿", comment = "bie" },
        },
        ["bie a"] = {
            { text = "别啊", comment = "bie a" },
        },
        ["bie ai"] = {
            { text = "别爱", comment = "bie ai" },
        },
        ["bie an"] = {
            { text = "别按", comment = "bie an" },
        },
        ["bie ao"] = {
            { text = "别熬", comment = "bie ao" },
        },
        ["bie bu"] = {
            { text = "别不", comment = "bie bu" },
        },
        ["bie e"] = {
            { text = "别饿", comment = "bie e" },
        },
        ["bie wo"] = {
            { text = "别我", comment = "bie wo" },
        },
        ["bie xu"] = {
            { text = "别虚", comment = "bie xu" },
            { text = "别绪", comment = "bie xu" },
        },
        ["bie ye"] = {
            { text = "别业", comment = "bie ye" },
        },
        ["bie yu"] = {
            { text = "别与", comment = "bie yu" },
        },
        ["bin an"] = {
            { text = "滨安", comment = "bin an" },
        },
        ["bin yu"] = {
            { text = "宾语", comment = "bin yu" },
            { text = "濒于", comment = "bin yu" },
            { text = "彬宇", comment = "bin yu" },
            { text = "宾语", comment = "bin yu" },
            { text = "濒于", comment = "bin yu" },
            { text = "彬宇", comment = "bin yu" },
        },
        ["bing a"] = {
            { text = "病啊", comment = "bing a" },
        },
        ["bing an"] = {
            { text = "病案", comment = "bing an" },
            { text = "并按", comment = "bing an" },
            { text = "并案", comment = "bing an" },
        },
        ["bing bu"] = {
            { text = "并不", comment = "bing bu" },
            { text = "兵部", comment = "bing bu" },
            { text = "丙部", comment = "bing bu" },
        },
        ["bing xu"] = {
            { text = "丙戌", comment = "bing xu" },
            { text = "并序", comment = "bing xu" },
            { text = "炳旭", comment = "bing xu" },
        },
        ["bing ye"] = {
            { text = "冰爷", comment = "bing ye" },
            { text = "丙夜", comment = "bing ye" },
        },
        ["bo"] = {
            { text = "波", comment = "bo" },
            { text = "博", comment = "bo" },
            { text = "播", comment = "bo" },
            { text = "薄", comment = "bo" },
            { text = "拨", comment = "bo" },
            { text = "伯", comment = "bo" },
            { text = "啵", comment = "bo" },
            { text = "剥", comment = "bo" },
            { text = "柏", comment = "bo" },
            { text = "卜", comment = "bo" },
            { text = "搏", comment = "bo" },
            { text = "泊", comment = "bo" },
            { text = "玻", comment = "bo" },
            { text = "勃", comment = "bo" },
            { text = "驳", comment = "bo" },
            { text = "铂", comment = "bo" },
            { text = "脖", comment = "bo" },
            { text = "钵", comment = "bo" },
            { text = "渤", comment = "bo" },
            { text = "帛", comment = "bo" },
            { text = "箔", comment = "bo" },
            { text = "跛", comment = "bo" },
            { text = "膊", comment = "bo" },
            { text = "菠", comment = "bo" },
            { text = "舶", comment = "bo" },
            { text = "钹", comment = "bo" },
            { text = "亳", comment = "bo" },
            { text = "簸", comment = "bo" },
            { text = "擘", comment = "bo" },
            { text = "檗", comment = "bo" },
            { text = "孛", comment = "bo" },
            { text = "砵", comment = "bo" },
            { text = "饽", comment = "bo" },
            { text = "浡", comment = "bo" },
            { text = "僰", comment = "bo" },
            { text = "镈", comment = "bo" },
            { text = "礴", comment = "bo" },
            { text = "鲌", comment = "bo" },
            { text = "鹁", comment = "bo" },
            { text = "踣", comment = "bo" },
            { text = "嶓", comment = "bo" },
            { text = "般", comment = "bo" },
            { text = "哱", comment = "bo" },
            { text = "珀", comment = "bo" },
            { text = "蕃", comment = "bo" },
            { text = "趵", comment = "bo" },
            { text = "艴", comment = "bo" },
            { text = "欂", comment = "bo" },
            { text = "袯", comment = "bo" },
            { text = "馞", comment = "bo" },
            { text = "茀", comment = "bo" },
            { text = "榑", comment = "bo" },
            { text = "妭", comment = "bo" },
            { text = "簿", comment = "bo" },
            { text = "𬭛", comment = "bo" },
        },
        ["bo bo"] = {
            { text = "波波", comment = "bo bo" },
            { text = "啵啵", comment = "bo bo" },
            { text = "伯伯", comment = "bo bo" },
            { text = "博博", comment = "bo bo" },
            { text = "勃勃", comment = "bo bo" },
            { text = "饽饽", comment = "bo bo" },
            { text = "播播", comment = "bo bo" },
            { text = "趵趵", comment = "bo bo" },
            { text = "膊膊", comment = "bo bo" },
        },
        ["bo bu"] = {
            { text = "拨补", comment = "bo bu" },
            { text = "玻布", comment = "bo bu" },
            { text = "玻补", comment = "bo bu" },
        },
        ["bo hao"] = {
            { text = "拨号", comment = "bo hao" },
            { text = "博豪", comment = "bo hao" },
            { text = "博浩", comment = "bo hao" },
            { text = "跛豪", comment = "bo hao" },
            { text = "柏豪", comment = "bo hao" },
            { text = "博皓", comment = "bo hao" },
            { text = "博昊", comment = "bo hao" },
            { text = "伯豪", comment = "bo hao" },
        },
        ["bo huai"] = {
            { text = "博怀", comment = "bo huai" },
        },
        ["bo ou"] = {
            { text = "博欧", comment = "bo ou" },
        },
        ["bo ri"] = {
            { text = "博日", comment = "bo ri" },
        },
        ["bu"] = {
            { text = "不", comment = "bu" },
            { text = "部", comment = "bu" },
            { text = "补", comment = "bu" },
            { text = "步", comment = "bu" },
            { text = "布", comment = "bu" },
            { text = "簿", comment = "bu" },
            { text = "捕", comment = "bu" },
            { text = "卜", comment = "bu" },
            { text = "埠", comment = "bu" },
            { text = "卟", comment = "bu" },
            { text = "怖", comment = "bu" },
            { text = "哺", comment = "bu" },
            { text = "埔", comment = "bu" },
            { text = "钚", comment = "bu" },
            { text = "堡", comment = "bu" },
            { text = "埗", comment = "bu" },
            { text = "逋", comment = "bu" },
            { text = "晡", comment = "bu" },
            { text = "瓿", comment = "bu" },
            { text = "钸", comment = "bu" },
            { text = "醭", comment = "bu" },
            { text = "蔀", comment = "bu" },
            { text = "薄", comment = "bu" },
            { text = "𫐓", comment = "bu" },
            { text = "𬷕", comment = "bu" },
        },
        ["bu a"] = {
            { text = "不啊", comment = "bu a" },
        },
        ["bu ai"] = {
            { text = "不爱", comment = "bu ai" },
            { text = "不矮", comment = "bu ai" },
            { text = "不挨", comment = "bu ai" },
            { text = "不碍", comment = "bu ai" },
        },
        ["bu ai guo"] = {
            { text = "不爱国", comment = "bu ai guo" },
        },
        ["bu an"] = {
            { text = "不安", comment = "bu an" },
            { text = "不按", comment = "bu an" },
        },
        ["bu ba"] = {
            { text = "不把", comment = "bu ba" },
            { text = "不拔", comment = "bu ba" },
            { text = "不吧", comment = "bu ba" },
            { text = "补吧", comment = "bu ba" },
        },
        ["bu bai"] = {
            { text = "不败", comment = "bu bai" },
            { text = "不白", comment = "bu bai" },
            { text = "不摆", comment = "bu bai" },
            { text = "不拜", comment = "bu bai" },
            { text = "补白", comment = "bu bai" },
        },
        ["bu ban"] = {
            { text = "补办", comment = "bu ban" },
            { text = "不办", comment = "bu ban" },
            { text = "补班", comment = "bu ban" },
            { text = "不搬", comment = "bu ban" },
            { text = "补板", comment = "bu ban" },
            { text = "布板", comment = "bu ban" },
            { text = "不伴", comment = "bu ban" },
            { text = "部办", comment = "bu ban" },
            { text = "补版", comment = "bu ban" },
        },
        ["bu bang"] = {
            { text = "不帮", comment = "bu bang" },
            { text = "不绑", comment = "bu bang" },
        },
        ["bu bao"] = {
            { text = "不报", comment = "bu bao" },
            { text = "不抱", comment = "bu bao" },
            { text = "不包", comment = "bu bao" },
            { text = "不保", comment = "bu bao" },
            { text = "补报", comment = "bu bao" },
            { text = "不爆", comment = "bu bao" },
            { text = "不饱", comment = "bu bao" },
            { text = "布包", comment = "bu bao" },
            { text = "不薄", comment = "bu bao" },
            { text = "补宝", comment = "bu bao" },
        },
        ["bu bei"] = {
            { text = "不被", comment = "bu bei" },
            { text = "不背", comment = "bu bei" },
            { text = "不备", comment = "bu bei" },
            { text = "不悲", comment = "bu bei" },
        },
        ["bu ben"] = {
            { text = "不笨", comment = "bu ben" },
        },
        ["bu bi"] = {
            { text = "不必", comment = "bu bi" },
            { text = "不比", comment = "bu bi" },
            { text = "不逼", comment = "bu bi" },
            { text = "布比", comment = "bu bi" },
        },
        ["bu bian"] = {
            { text = "不变", comment = "bu bian" },
            { text = "不便", comment = "bu bian" },
            { text = "部编", comment = "bu bian" },
            { text = "布边", comment = "bu bian" },
            { text = "补编", comment = "bu bian" },
        },
        ["bu biao"] = {
            { text = "布标", comment = "bu biao" },
            { text = "不标", comment = "bu biao" },
            { text = "补标", comment = "bu biao" },
            { text = "不表", comment = "bu biao" },
            { text = "部标", comment = "bu biao" },
        },
        ["bu bing"] = {
            { text = "补兵", comment = "bu bing" },
            { text = "步兵", comment = "bu bing" },
            { text = "不冰", comment = "bu bing" },
            { text = "布病", comment = "bu bing" },
        },
        ["bu bo"] = {
            { text = "不播", comment = "bu bo" },
            { text = "补播", comment = "bu bo" },
            { text = "布帛", comment = "bu bo" },
        },
        ["bu bu"] = {
            { text = "补补", comment = "bu bu" },
            { text = "不不", comment = "bu bu" },
            { text = "不补", comment = "bu bu" },
            { text = "步步", comment = "bu bu" },
            { text = "布布", comment = "bu bu" },
            { text = "卜卜", comment = "bu bu" },
            { text = "咘咘", comment = "bu bu" },
            { text = "部部", comment = "bu bu" },
        },
        ["bu bu zhang"] = {
            { text = "部部长", comment = "bu bu zhang" },
        },
        ["bu cai"] = {
            { text = "不采", comment = "bu cai" },
            { text = "不猜", comment = "bu cai" },
            { text = "不才", comment = "bu cai" },
            { text = "不菜", comment = "bu cai" },
            { text = "不睬", comment = "bu cai" },
            { text = "不踩", comment = "bu cai" },
            { text = "补采", comment = "bu cai" },
            { text = "不裁", comment = "bu cai" },
            { text = "补菜", comment = "bu cai" },
            { text = "布菜", comment = "bu cai" },
        },
        ["bu cao"] = {
            { text = "布草", comment = "bu cao" },
            { text = "不糙", comment = "bu cao" },
            { text = "补槽", comment = "bu cao" },
        },
        ["bu ceng"] = {
            { text = "不曾", comment = "bu ceng" },
        },
        ["bu cha"] = {
            { text = "不差", comment = "bu cha" },
            { text = "补差", comment = "bu cha" },
            { text = "不查", comment = "bu cha" },
            { text = "不插", comment = "bu cha" },
        },
        ["bu chang"] = {
            { text = "补偿", comment = "bu chang" },
            { text = "不长", comment = "bu chang" },
            { text = "不畅", comment = "bu chang" },
            { text = "不常", comment = "bu chang" },
            { text = "步长", comment = "bu chang" },
            { text = "不唱", comment = "bu chang" },
            { text = "布场", comment = "bu chang" },
            { text = "布厂", comment = "bu chang" },
        },
        ["bu chao"] = {
            { text = "不超", comment = "bu chao" },
            { text = "不吵", comment = "bu chao" },
            { text = "不抄", comment = "bu chao" },
            { text = "不炒", comment = "bu chao" },
            { text = "不潮", comment = "bu chao" },
        },
        ["bu chen"] = {
            { text = "不沉", comment = "bu chen" },
            { text = "布衬", comment = "bu chen" },
        },
        ["bu cheng"] = {
            { text = "不成", comment = "bu cheng" },
            { text = "不撑", comment = "bu cheng" },
            { text = "补成", comment = "bu cheng" },
            { text = "不称", comment = "bu cheng" },
            { text = "不逞", comment = "bu cheng" },
        },
        ["bu chi"] = {
            { text = "不吃", comment = "bu chi" },
            { text = "不迟", comment = "bu chi" },
            { text = "不齿", comment = "bu chi" },
            { text = "不耻", comment = "bu chi" },
            { text = "不啻", comment = "bu chi" },
        },
        ["bu chong"] = {
            { text = "补充", comment = "bu chong" },
            { text = "不冲", comment = "bu chong" },
            { text = "不充", comment = "bu chong" },
            { text = "捕虫", comment = "bu chong" },
        },
        ["bu chu"] = {
            { text = "不出", comment = "bu chu" },
            { text = "不处", comment = "bu chu" },
            { text = "补出", comment = "bu chu" },
            { text = "步出", comment = "bu chu" },
        },
        ["bu chuang"] = {
            { text = "不创", comment = "bu chuang" },
            { text = "布床", comment = "bu chuang" },
        },
        ["bu cong"] = {
            { text = "不从", comment = "bu cong" },
        },
        ["bu cuo le"] = {
            { text = "不错了", comment = "bu cuo le" },
        },
        ["bu da"] = {
            { text = "不大", comment = "bu da" },
            { text = "不打", comment = "bu da" },
            { text = "不搭", comment = "bu da" },
            { text = "补打", comment = "bu da" },
            { text = "不达", comment = "bu da" },
            { text = "不答", comment = "bu da" },
            { text = "布达", comment = "bu da" },
        },
        ["bu dai"] = {
            { text = "不带", comment = "bu dai" },
            { text = "不戴", comment = "bu dai" },
            { text = "布袋", comment = "bu dai" },
            { text = "不待", comment = "bu dai" },
            { text = "不呆", comment = "bu dai" },
            { text = "布带", comment = "bu dai" },
        },
        ["bu dan"] = {
            { text = "补单", comment = "bu dan" },
            { text = "不但", comment = "bu dan" },
            { text = "不单", comment = "bu dan" },
            { text = "不丹", comment = "bu dan" },
            { text = "不淡", comment = "bu dan" },
            { text = "不惮", comment = "bu dan" },
        },
        ["bu de"] = {
            { text = "不得", comment = "bu de" },
            { text = "补得", comment = "bu de" },
            { text = "补的", comment = "bu de" },
            { text = "布的", comment = "bu de" },
            { text = "部的", comment = "bu de" },
            { text = "不的", comment = "bu de" },
            { text = "布德", comment = "bu de" },
        },
        ["bu de ke"] = {
            { text = "补的课", comment = "bu de ke" },
        },
        ["bu de li"] = {
            { text = "不得力", comment = "bu de li" },
        },
        ["bu de ya"] = {
            { text = "补的牙", comment = "bu de ya" },
        },
        ["bu deng"] = {
            { text = "不等", comment = "bu deng" },
            { text = "不登", comment = "bu deng" },
            { text = "补登", comment = "bu deng" },
            { text = "布灯", comment = "bu deng" },
            { text = "布凳", comment = "bu deng" },
        },
        ["bu di"] = {
            { text = "不低", comment = "bu di" },
            { text = "不敌", comment = "bu di" },
            { text = "不滴", comment = "bu di" },
            { text = "不抵", comment = "bu di" },
            { text = "布底", comment = "bu di" },
            { text = "不第", comment = "bu di" },
        },
        ["bu di e"] = {
            { text = "布迪厄", comment = "bu di e" },
        },
        ["bu dian"] = {
            { text = "不点", comment = "bu dian" },
            { text = "补点", comment = "bu dian" },
            { text = "布点", comment = "bu dian" },
            { text = "不垫", comment = "bu dian" },
            { text = "补店", comment = "bu dian" },
            { text = "补电", comment = "bu dian" },
            { text = "布店", comment = "bu dian" },
            { text = "布垫", comment = "bu dian" },
            { text = "布甸", comment = "bu dian" },
        },
        ["bu die"] = {
            { text = "不跌", comment = "bu die" },
            { text = "补跌", comment = "bu die" },
            { text = "不叠", comment = "bu die" },
            { text = "不迭", comment = "bu die" },
        },
        ["bu ding"] = {
            { text = "不定", comment = "bu ding" },
            { text = "布丁", comment = "bu ding" },
            { text = "补丁", comment = "bu ding" },
            { text = "不订", comment = "bu ding" },
            { text = "不顶", comment = "bu ding" },
            { text = "补订", comment = "bu ding" },
            { text = "补定", comment = "bu ding" },
        },
        ["bu dong"] = {
            { text = "不懂", comment = "bu dong" },
            { text = "不动", comment = "bu dong" },
            { text = "不冻", comment = "bu dong" },
            { text = "补洞", comment = "bu dong" },
            { text = "不东", comment = "bu dong" },
        },
        ["bu dou"] = {
            { text = "不都", comment = "bu dou" },
            { text = "不逗", comment = "bu dou" },
            { text = "不抖", comment = "bu dou" },
            { text = "不斗", comment = "bu dou" },
            { text = "布兜", comment = "bu dou" },
        },
        ["bu du"] = {
            { text = "不读", comment = "bu du" },
            { text = "不赌", comment = "bu du" },
            { text = "不堵", comment = "bu du" },
            { text = "不渡", comment = "bu du" },
            { text = "不独", comment = "bu du" },
        },
        ["bu duan"] = {
            { text = "不断", comment = "bu duan" },
            { text = "不短", comment = "bu duan" },
            { text = "不端", comment = "bu duan" },
            { text = "补短", comment = "bu duan" },
        },
        ["bu dui"] = {
            { text = "不对", comment = "bu dui" },
            { text = "部队", comment = "bu dui" },
            { text = "不怼", comment = "bu dui" },
        },
        ["bu dun"] = {
            { text = "不蹲", comment = "bu dun" },
        },
        ["bu duo"] = {
            { text = "不多", comment = "bu duo" },
            { text = "不躲", comment = "bu duo" },
        },
        ["bu en"] = {
            { text = "布恩", comment = "bu en" },
            { text = "不嗯", comment = "bu en" },
            { text = "不恩", comment = "bu en" },
        },
        ["bu er"] = {
            { text = "不二", comment = "bu er" },
            { text = "布尔", comment = "bu er" },
            { text = "不尔", comment = "bu er" },
        },
        ["bu fa"] = {
            { text = "不发", comment = "bu fa" },
            { text = "步伐", comment = "bu fa" },
            { text = "补发", comment = "bu fa" },
            { text = "不乏", comment = "bu fa" },
            { text = "不法", comment = "bu fa" },
            { text = "不罚", comment = "bu fa" },
            { text = "步法", comment = "bu fa" },
            { text = "补法", comment = "bu fa" },
        },
        ["bu fan"] = {
            { text = "不烦", comment = "bu fan" },
            { text = "不返", comment = "bu fan" },
            { text = "不凡", comment = "bu fan" },
            { text = "不翻", comment = "bu fan" },
            { text = "补番", comment = "bu fan" },
            { text = "不犯", comment = "bu fan" },
            { text = "不反", comment = "bu fan" },
            { text = "卜凡", comment = "bu fan" },
            { text = "补返", comment = "bu fan" },
            { text = "布凡", comment = "bu fan" },
            { text = "步凡", comment = "bu fan" },
            { text = "布梵", comment = "bu fan" },
        },
        ["bu fang"] = {
            { text = "不放", comment = "bu fang" },
            { text = "不妨", comment = "bu fang" },
            { text = "布放", comment = "bu fang" },
            { text = "不防", comment = "bu fang" },
            { text = "不方", comment = "bu fang" },
            { text = "布防", comment = "bu fang" },
            { text = "补防", comment = "bu fang" },
            { text = "补方", comment = "bu fang" },
            { text = "哺坊", comment = "bu fang" },
            { text = "捕房", comment = "bu fang" },
        },
        ["bu fei"] = {
            { text = "不菲", comment = "bu fei" },
            { text = "不肥", comment = "bu fei" },
            { text = "不飞", comment = "bu fei" },
            { text = "不费", comment = "bu fei" },
            { text = "补费", comment = "bu fei" },
            { text = "布菲", comment = "bu fei" },
        },
        ["bu fen"] = {
            { text = "不分", comment = "bu fen" },
            { text = "部分", comment = "bu fen" },
            { text = "补分", comment = "bu fen" },
            { text = "部份", comment = "bu fen" },
            { text = "不忿", comment = "bu fen" },
            { text = "卟吩", comment = "bu fen" },
        },
        ["bu feng"] = {
            { text = "不封", comment = "bu feng" },
            { text = "补风", comment = "bu feng" },
            { text = "布冯", comment = "bu feng" },
            { text = "卜蜂", comment = "bu feng" },
            { text = "补缝", comment = "bu feng" },
            { text = "布封", comment = "bu feng" },
            { text = "步凤", comment = "bu feng" },
        },
        ["bu fu"] = {
            { text = "不服", comment = "bu fu" },
            { text = "不符", comment = "bu fu" },
            { text = "不付", comment = "bu fu" },
            { text = "不负", comment = "bu fu" },
            { text = "不复", comment = "bu fu" },
            { text = "补付", comment = "bu fu" },
            { text = "不敷", comment = "bu fu" },
            { text = "步幅", comment = "bu fu" },
            { text = "不腐", comment = "bu fu" },
            { text = "补服", comment = "bu fu" },
        },
        ["bu gan"] = {
            { text = "不敢", comment = "bu gan" },
            { text = "不干", comment = "bu gan" },
            { text = "不甘", comment = "bu gan" },
            { text = "不赶", comment = "bu gan" },
            { text = "不肝", comment = "bu gan" },
            { text = "不感", comment = "bu gan" },
        },
        ["bu gang"] = {
            { text = "不港", comment = "bu gang" },
            { text = "补岗", comment = "bu gang" },
        },
        ["bu gao"] = {
            { text = "不高", comment = "bu gao" },
            { text = "不搞", comment = "bu gao" },
            { text = "不告", comment = "bu gao" },
            { text = "布告", comment = "bu gao" },
            { text = "布高", comment = "bu gao" },
        },
        ["bu ge"] = {
            { text = "补个", comment = "bu ge" },
            { text = "不割", comment = "bu ge" },
            { text = "不鸽", comment = "bu ge" },
            { text = "布哥", comment = "bu ge" },
            { text = "布鸽", comment = "bu ge" },
            { text = "布格", comment = "bu ge" },
            { text = "步哥", comment = "bu ge" },
        },
        ["bu gen"] = {
            { text = "不跟", comment = "bu gen" },
        },
        ["bu gong"] = {
            { text = "不公", comment = "bu gong" },
            { text = "不供", comment = "bu gong" },
            { text = "不攻", comment = "bu gong" },
            { text = "不共", comment = "bu gong" },
            { text = "卜工", comment = "bu gong" },
            { text = "步弓", comment = "bu gong" },
            { text = "不恭", comment = "bu gong" },
        },
        ["bu gu"] = {
            { text = "不顾", comment = "bu gu" },
            { text = "布谷", comment = "bu gu" },
            { text = "不咕", comment = "bu gu" },
            { text = "不孤", comment = "bu gu" },
            { text = "不谷", comment = "bu gu" },
        },
        ["bu guan"] = {
            { text = "不管", comment = "bu guan" },
            { text = "不关", comment = "bu guan" },
            { text = "不惯", comment = "bu guan" },
            { text = "布管", comment = "bu guan" },
        },
        ["bu guang"] = {
            { text = "不光", comment = "bu guang" },
            { text = "补光", comment = "bu guang" },
            { text = "不逛", comment = "bu guang" },
            { text = "布光", comment = "bu guang" },
        },
        ["bu gui"] = {
            { text = "不贵", comment = "bu gui" },
            { text = "不归", comment = "bu gui" },
            { text = "不轨", comment = "bu gui" },
        },
        ["bu guo"] = {
            { text = "不过", comment = "bu guo" },
            { text = "补过", comment = "bu guo" },
            { text = "补锅", comment = "bu guo" },
            { text = "不果", comment = "bu guo" },
        },
        ["bu hai"] = {
            { text = "不还", comment = "bu hai" },
            { text = "不嗨", comment = "bu hai" },
            { text = "不害", comment = "bu hai" },
            { text = "布海", comment = "bu hai" },
        },
        ["bu hai shi"] = {
            { text = "不还是", comment = "bu hai shi" },
        },
        ["bu han"] = {
            { text = "不含", comment = "bu han" },
            { text = "不喊", comment = "bu han" },
            { text = "补焊", comment = "bu han" },
            { text = "不焊", comment = "bu han" },
        },
        ["bu hang"] = {
            { text = "布行", comment = "bu hang" },
        },
        ["bu hao"] = {
            { text = "不好", comment = "bu hao" },
            { text = "补好", comment = "bu hao" },
            { text = "不耗", comment = "bu hao" },
            { text = "补号", comment = "bu hao" },
            { text = "布号", comment = "bu hao" },
        },
        ["bu he"] = {
            { text = "不喝", comment = "bu he" },
            { text = "不和", comment = "bu he" },
            { text = "不合", comment = "bu he" },
            { text = "布赫", comment = "bu he" },
            { text = "布和", comment = "bu he" },
            { text = "埠河", comment = "bu he" },
            { text = "部和", comment = "bu he" },
        },
        ["bu heng"] = {
            { text = "不哼", comment = "bu heng" },
        },
        ["bu hong"] = {
            { text = "不红", comment = "bu hong" },
            { text = "不哄", comment = "bu hong" },
        },
        ["bu hou"] = {
            { text = "不厚", comment = "bu hou" },
            { text = "不候", comment = "bu hou" },
        },
        ["bu hu"] = {
            { text = "不糊", comment = "bu hu" },
            { text = "不胡", comment = "bu hu" },
        },
        ["bu hua"] = {
            { text = "不花", comment = "bu hua" },
            { text = "不画", comment = "bu hua" },
            { text = "不化", comment = "bu hua" },
            { text = "不滑", comment = "bu hua" },
            { text = "不划", comment = "bu hua" },
            { text = "补划", comment = "bu hua" },
            { text = "补花", comment = "bu hua" },
            { text = "埔华", comment = "bu hua" },
        },
        ["bu huai"] = {
            { text = "不坏", comment = "bu huai" },
        },
        ["bu huan"] = {
            { text = "不换", comment = "bu huan" },
            { text = "不欢", comment = "bu huan" },
            { text = "补还", comment = "bu huan" },
            { text = "补换", comment = "bu huan" },
        },
        ["bu huang"] = {
            { text = "不慌", comment = "bu huang" },
            { text = "不黄", comment = "bu huang" },
            { text = "不遑", comment = "bu huang" },
        },
        ["bu hui"] = {
            { text = "不会", comment = "bu hui" },
            { text = "不回", comment = "bu hui" },
            { text = "补回", comment = "bu hui" },
            { text = "不悔", comment = "bu hui" },
            { text = "补灰", comment = "bu hui" },
            { text = "不讳", comment = "bu hui" },
        },
        ["bu huo"] = {
            { text = "补货", comment = "bu huo" },
            { text = "捕获", comment = "bu huo" },
            { text = "不活", comment = "bu huo" },
            { text = "不火", comment = "bu huo" },
            { text = "不惑", comment = "bu huo" },
        },
        ["bu ji"] = {
            { text = "不急", comment = "bu ji" },
            { text = "不及", comment = "bu ji" },
            { text = "不计", comment = "bu ji" },
            { text = "补寄", comment = "bu ji" },
            { text = "不寄", comment = "bu ji" },
            { text = "布吉", comment = "bu ji" },
            { text = "不记", comment = "bu ji" },
            { text = "补记", comment = "bu ji" },
            { text = "不济", comment = "bu ji" },
            { text = "不羁", comment = "bu ji" },
            { text = "不挤", comment = "bu ji" },
            { text = "部级", comment = "bu ji" },
            { text = "簿记", comment = "bu ji" },
            { text = "补剂", comment = "bu ji" },
            { text = "补集", comment = "bu ji" },
            { text = "捕集", comment = "bu ji" },
            { text = "布基", comment = "bu ji" },
            { text = "不吉", comment = "bu ji" },
            { text = "部机", comment = "bu ji" },
            { text = "卜集", comment = "bu ji" },
            { text = "簿籍", comment = "bu ji" },
            { text = "哺鸡", comment = "bu ji" },
        },
        ["bu jia"] = {
            { text = "不加", comment = "bu jia" },
            { text = "不佳", comment = "bu jia" },
            { text = "不假", comment = "bu jia" },
            { text = "布甲", comment = "bu jia" },
            { text = "不嫁", comment = "bu jia" },
            { text = "补加", comment = "bu jia" },
            { text = "补假", comment = "bu jia" },
            { text = "补钾", comment = "bu jia" },
            { text = "补价", comment = "bu jia" },
            { text = "不价", comment = "bu jia" },
        },
        ["bu jian"] = {
            { text = "不见", comment = "bu jian" },
            { text = "部件", comment = "bu jian" },
            { text = "不减", comment = "bu jian" },
            { text = "补件", comment = "bu jian" },
            { text = "不捡", comment = "bu jian" },
            { text = "不剪", comment = "bu jian" },
            { text = "不建", comment = "bu jian" },
            { text = "不检", comment = "bu jian" },
            { text = "补检", comment = "bu jian" },
            { text = "补建", comment = "bu jian" },
            { text = "布建", comment = "bu jian" },
            { text = "不坚", comment = "bu jian" },
            { text = "补间", comment = "bu jian" },
        },
        ["bu jiang"] = {
            { text = "不讲", comment = "bu jiang" },
            { text = "不降", comment = "bu jiang" },
            { text = "不将", comment = "bu jiang" },
            { text = "部将", comment = "bu jiang" },
        },
        ["bu jiao"] = {
            { text = "不叫", comment = "bu jiao" },
            { text = "不交", comment = "bu jiao" },
            { text = "补交", comment = "bu jiao" },
            { text = "补缴", comment = "bu jiao" },
            { text = "补觉", comment = "bu jiao" },
            { text = "不教", comment = "bu jiao" },
            { text = "补胶", comment = "bu jiao" },
            { text = "不缴", comment = "bu jiao" },
            { text = "补角", comment = "bu jiao" },
        },
        ["bu jie"] = {
            { text = "不接", comment = "bu jie" },
            { text = "不借", comment = "bu jie" },
            { text = "不解", comment = "bu jie" },
            { text = "不结", comment = "bu jie" },
            { text = "不洁", comment = "bu jie" },
            { text = "不截", comment = "bu jie" },
            { text = "不竭", comment = "bu jie" },
            { text = "补结", comment = "bu jie" },
            { text = "布姐", comment = "bu jie" },
        },
        ["bu jin"] = {
            { text = "不仅", comment = "bu jin" },
            { text = "不进", comment = "bu jin" },
            { text = "不禁", comment = "bu jin" },
            { text = "不近", comment = "bu jin" },
            { text = "不紧", comment = "bu jin" },
            { text = "不尽", comment = "bu jin" },
            { text = "步进", comment = "bu jin" },
            { text = "补进", comment = "bu jin" },
        },
        ["bu jin jin"] = {
            { text = "不仅仅", comment = "bu jin jin" },
        },
        ["bu jing"] = {
            { text = "不经", comment = "bu jing" },
            { text = "不精", comment = "bu jing" },
            { text = "布景", comment = "bu jing" },
            { text = "不敬", comment = "bu jing" },
            { text = "不净", comment = "bu jing" },
            { text = "不惊", comment = "bu jing" },
            { text = "捕鲸", comment = "bu jing" },
            { text = "布警", comment = "bu jing" },
        },
        ["bu jing li"] = {
            { text = "不经历", comment = "bu jing li" },
            { text = "部经理", comment = "bu jing li" },
            { text = "卜经理", comment = "bu jing li" },
        },
        ["bu jiu"] = {
            { text = "不就", comment = "bu jiu" },
            { text = "不久", comment = "bu jiu" },
            { text = "补救", comment = "bu jiu" },
            { text = "不救", comment = "bu jiu" },
            { text = "补酒", comment = "bu jiu" },
        },
        ["bu ju"] = {
            { text = "布局", comment = "bu ju" },
            { text = "不惧", comment = "bu ju" },
            { text = "不举", comment = "bu ju" },
            { text = "步距", comment = "bu ju" },
            { text = "不具", comment = "bu ju" },
            { text = "不聚", comment = "bu ju" },
            { text = "不拒", comment = "bu ju" },
            { text = "不拘", comment = "bu ju" },
            { text = "补剧", comment = "bu ju" },
            { text = "卜居", comment = "bu ju" },
            { text = "补苴", comment = "bu ju" },
        },
        ["bu juan"] = {
            { text = "不捐", comment = "bu juan" },
            { text = "布卷", comment = "bu juan" },
            { text = "不卷", comment = "bu juan" },
            { text = "不倦", comment = "bu juan" },
        },
        ["bu jue"] = {
            { text = "不觉", comment = "bu jue" },
            { text = "不决", comment = "bu jue" },
            { text = "不绝", comment = "bu jue" },
        },
        ["bu jue de"] = {
            { text = "不觉得", comment = "bu jue de" },
        },
        ["bu jun"] = {
            { text = "不均", comment = "bu jun" },
            { text = "不俊", comment = "bu jun" },
        },
        ["bu ka"] = {
            { text = "不卡", comment = "bu ka" },
            { text = "补卡", comment = "bu ka" },
            { text = "布卡", comment = "bu ka" },
        },
        ["bu kai"] = {
            { text = "不开", comment = "bu kai" },
            { text = "补开", comment = "bu kai" },
        },
        ["bu kan"] = {
            { text = "不看", comment = "bu kan" },
            { text = "不堪", comment = "bu kan" },
            { text = "不砍", comment = "bu kan" },
            { text = "补勘", comment = "bu kan" },
        },
        ["bu kang"] = {
            { text = "不抗", comment = "bu kang" },
            { text = "不康", comment = "bu kang" },
        },
        ["bu ke"] = {
            { text = "不可", comment = "bu ke" },
            { text = "补课", comment = "bu ke" },
            { text = "不氪", comment = "bu ke" },
            { text = "不克", comment = "bu ke" },
            { text = "布克", comment = "bu ke" },
            { text = "不渴", comment = "bu ke" },
            { text = "不磕", comment = "bu ke" },
            { text = "不刻", comment = "bu ke" },
            { text = "步科", comment = "bu ke" },
            { text = "部课", comment = "bu ke" },
            { text = "卜课", comment = "bu ke" },
            { text = "逋客", comment = "bu ke" },
        },
        ["bu ke yi"] = {
            { text = "不可以", comment = "bu ke yi" },
            { text = "不刻意", comment = "bu ke yi" },
        },
        ["bu ken"] = {
            { text = "不肯", comment = "bu ken" },
        },
        ["bu kong"] = {
            { text = "不空", comment = "bu kong" },
            { text = "布控", comment = "bu kong" },
            { text = "不控", comment = "bu kong" },
            { text = "补孔", comment = "bu kong" },
            { text = "布孔", comment = "bu kong" },
            { text = "补空", comment = "bu kong" },
        },
        ["bu ku"] = {
            { text = "不哭", comment = "bu ku" },
            { text = "不苦", comment = "bu ku" },
            { text = "补库", comment = "bu ku" },
            { text = "布裤", comment = "bu ku" },
        },
        ["bu kuai"] = {
            { text = "不快", comment = "bu kuai" },
            { text = "捕快", comment = "bu kuai" },
            { text = "布块", comment = "bu kuai" },
            { text = "补块", comment = "bu kuai" },
        },
        ["bu kuan"] = {
            { text = "补款", comment = "bu kuan" },
            { text = "不宽", comment = "bu kuan" },
            { text = "布款", comment = "bu kuan" },
        },
        ["bu kun"] = {
            { text = "不困", comment = "bu kun" },
        },
        ["bu la"] = {
            { text = "不拉", comment = "bu la" },
            { text = "不辣", comment = "bu la" },
            { text = "不啦", comment = "bu la" },
            { text = "布拉", comment = "bu la" },
            { text = "不落", comment = "bu la" },
        },
        ["bu lai"] = {
            { text = "不来", comment = "bu lai" },
            { text = "不赖", comment = "bu lai" },
            { text = "补来", comment = "bu lai" },
            { text = "布莱", comment = "bu lai" },
        },
        ["bu lai de"] = {
            { text = "不来的", comment = "bu lai de" },
            { text = "布莱德", comment = "bu lai de" },
        },
        ["bu lai ke"] = {
            { text = "布莱克", comment = "bu lai ke" },
        },
        ["bu lai mei"] = {
            { text = "不莱梅", comment = "bu lai mei" },
            { text = "不来梅", comment = "bu lai mei" },
            { text = "不莱玫", comment = "bu lai mei" },
        },
        ["bu lai te"] = {
            { text = "布莱特", comment = "bu lai te" },
        },
        ["bu lan"] = {
            { text = "不懒", comment = "bu lan" },
            { text = "不烂", comment = "bu lan" },
            { text = "不拦", comment = "bu lan" },
            { text = "布兰", comment = "bu lan" },
            { text = "补篮", comment = "bu lan" },
            { text = "补栏", comment = "bu lan" },
        },
        ["bu lan de"] = {
            { text = "布兰德", comment = "bu lan de" },
        },
        ["bu lan te"] = {
            { text = "布兰特", comment = "bu lan te" },
        },
        ["bu lang"] = {
            { text = "不浪", comment = "bu lang" },
            { text = "布朗", comment = "bu lang" },
        },
        ["bu lao shi"] = {
            { text = "不老实", comment = "bu lao shi" },
            { text = "卜老师", comment = "bu lao shi" },
            { text = "布老师", comment = "bu lao shi" },
            { text = "步老师", comment = "bu lao shi" },
        },
        ["bu le"] = {
            { text = "不了", comment = "bu le" },
            { text = "补了", comment = "bu le" },
            { text = "不乐", comment = "bu le" },
            { text = "布勒", comment = "bu le" },
        },
        ["bu lei"] = {
            { text = "不累", comment = "bu lei" },
            { text = "不勒", comment = "bu lei" },
            { text = "布雷", comment = "bu lei" },
            { text = "布蕾", comment = "bu lei" },
            { text = "不嘞", comment = "bu lei" },
            { text = "部类", comment = "bu lei" },
            { text = "不类", comment = "bu lei" },
            { text = "布儡", comment = "bu lei" },
        },
        ["bu li"] = {
            { text = "不理", comment = "bu li" },
            { text = "不离", comment = "bu li" },
            { text = "不利", comment = "bu li" },
            { text = "不力", comment = "bu li" },
            { text = "部里", comment = "bu li" },
            { text = "不立", comment = "bu li" },
            { text = "布里", comment = "bu li" },
            { text = "卟离", comment = "bu li" },
            { text = "堡里", comment = "bu li" },
        },
        ["bu lian"] = {
            { text = "不练", comment = "bu lian" },
            { text = "不连", comment = "bu lian" },
            { text = "布帘", comment = "bu lian" },
        },
        ["bu liang"] = {
            { text = "不良", comment = "bu liang" },
            { text = "不亮", comment = "bu liang" },
            { text = "不凉", comment = "bu liang" },
            { text = "补量", comment = "bu liang" },
            { text = "不量", comment = "bu liang" },
        },
        ["bu lin"] = {
            { text = "不吝", comment = "bu lin" },
            { text = "布林", comment = "bu lin" },
            { text = "卟啉", comment = "bu lin" },
        },
        ["bu ling"] = {
            { text = "不灵", comment = "bu ling" },
            { text = "不领", comment = "bu ling" },
            { text = "补领", comment = "bu ling" },
            { text = "不另", comment = "bu ling" },
        },
        ["bu long"] = {
            { text = "布隆", comment = "bu long" },
            { text = "不拢", comment = "bu long" },
            { text = "布龙", comment = "bu long" },
        },
        ["bu lu"] = {
            { text = "补录", comment = "bu lu" },
            { text = "不录", comment = "bu lu" },
            { text = "布鲁", comment = "bu lu" },
            { text = "不露", comment = "bu lu" },
            { text = "不撸", comment = "bu lu" },
        },
        ["bu lun"] = {
            { text = "不论", comment = "bu lun" },
            { text = "不伦", comment = "bu lun" },
            { text = "布轮", comment = "bu lun" },
            { text = "布伦", comment = "bu lun" },
        },
        ["bu luo"] = {
            { text = "部落", comment = "bu luo" },
            { text = "布罗", comment = "bu luo" },
            { text = "布洛", comment = "bu luo" },
        },
        ["bu lv"] = {
            { text = "步履", comment = "bu lv" },
            { text = "不绿", comment = "bu lv" },
        },
        ["bu ma"] = {
            { text = "不嘛", comment = "bu ma" },
            { text = "不骂", comment = "bu ma" },
            { text = "补码", comment = "bu ma" },
            { text = "补吗", comment = "bu ma" },
            { text = "布玛", comment = "bu ma" },
        },
        ["bu ma ta"] = {
            { text = "不骂他", comment = "bu ma ta" },
        },
        ["bu mai"] = {
            { text = "不买", comment = "bu mai" },
            { text = "不卖", comment = "bu mai" },
            { text = "补买", comment = "bu mai" },
            { text = "补麦", comment = "bu mai" },
        },
        ["bu man"] = {
            { text = "不满", comment = "bu man" },
            { text = "不慢", comment = "bu man" },
            { text = "布满", comment = "bu man" },
            { text = "补满", comment = "bu man" },
            { text = "不瞒", comment = "bu man" },
            { text = "布幔", comment = "bu man" },
        },
        ["bu mang a"] = {
            { text = "不忙啊", comment = "bu mang a" },
        },
        ["bu mao"] = {
            { text = "不毛", comment = "bu mao" },
            { text = "布帽", comment = "bu mao" },
        },
        ["bu mei"] = {
            { text = "不美", comment = "bu mei" },
            { text = "不寐", comment = "bu mei" },
            { text = "步美", comment = "bu mei" },
        },
        ["bu men"] = {
            { text = "部门", comment = "bu men" },
            { text = "不闷", comment = "bu men" },
        },
        ["bu meng"] = {
            { text = "不猛", comment = "bu meng" },
            { text = "不萌", comment = "bu meng" },
            { text = "不蒙", comment = "bu meng" },
            { text = "捕梦", comment = "bu meng" },
            { text = "步梦", comment = "bu meng" },
        },
        ["bu mi"] = {
            { text = "不迷", comment = "bu mi" },
            { text = "布米", comment = "bu mi" },
        },
        ["bu miao"] = {
            { text = "不妙", comment = "bu miao" },
            { text = "不秒", comment = "bu miao" },
            { text = "补苗", comment = "bu miao" },
        },
        ["bu min"] = {
            { text = "不敏", comment = "bu min" },
        },
        ["bu ming"] = {
            { text = "不明", comment = "bu ming" },
            { text = "不鸣", comment = "bu ming" },
        },
        ["bu mo"] = {
            { text = "不磨", comment = "bu mo" },
            { text = "不摸", comment = "bu mo" },
            { text = "补魔", comment = "bu mo" },
            { text = "布魔", comment = "bu mo" },
        },
        ["bu mu"] = {
            { text = "布姆", comment = "bu mu" },
        },
        ["bu na"] = {
            { text = "不拿", comment = "bu na" },
            { text = "不那", comment = "bu na" },
        },
        ["bu nai"] = {
            { text = "不耐", comment = "bu nai" },
            { text = "不奶", comment = "bu nai" },
        },
        ["bu nan"] = {
            { text = "不难", comment = "bu nan" },
        },
        ["bu nei"] = {
            { text = "不馁", comment = "bu nei" },
        },
        ["bu neng"] = {
            { text = "不能", comment = "bu neng" },
        },
        ["bu neng da"] = {
            { text = "不能打", comment = "bu neng da" },
        },
        ["bu ni"] = {
            { text = "不腻", comment = "bu ni" },
            { text = "补你", comment = "bu ni" },
            { text = "不你", comment = "bu ni" },
        },
        ["bu niao"] = {
            { text = "不鸟", comment = "bu niao" },
            { text = "不嬲", comment = "bu niao" },
        },
        ["bu ning"] = {
            { text = "不宁", comment = "bu ning" },
            { text = "不佞", comment = "bu ning" },
        },
        ["bu nuo"] = {
            { text = "不挪", comment = "bu nuo" },
        },
        ["bu ou"] = {
            { text = "布偶", comment = "bu ou" },
            { text = "布欧", comment = "bu ou" },
        },
        ["bu pa"] = {
            { text = "不怕", comment = "bu pa" },
            { text = "不爬", comment = "bu pa" },
        },
        ["bu pa si"] = {
            { text = "不怕死", comment = "bu pa si" },
        },
        ["bu pai"] = {
            { text = "不拍", comment = "bu pai" },
            { text = "补拍", comment = "bu pai" },
            { text = "不排", comment = "bu pai" },
            { text = "不派", comment = "bu pai" },
            { text = "补牌", comment = "bu pai" },
        },
        ["bu pan"] = {
            { text = "不判", comment = "bu pan" },
            { text = "不盘", comment = "bu pan" },
        },
        ["bu pao"] = {
            { text = "不跑", comment = "bu pao" },
            { text = "不泡", comment = "bu pao" },
            { text = "不抛", comment = "bu pao" },
        },
        ["bu pei"] = {
            { text = "不配", comment = "bu pei" },
            { text = "不赔", comment = "bu pei" },
            { text = "不陪", comment = "bu pei" },
            { text = "补配", comment = "bu pei" },
            { text = "补赔", comment = "bu pei" },
        },
        ["bu peng"] = {
            { text = "不碰", comment = "bu peng" },
        },
        ["bu pian"] = {
            { text = "不骗", comment = "bu pian" },
            { text = "补片", comment = "bu pian" },
            { text = "不偏", comment = "bu pian" },
            { text = "布片", comment = "bu pian" },
        },
        ["bu pin"] = {
            { text = "补品", comment = "bu pin" },
            { text = "部品", comment = "bu pin" },
            { text = "不拼", comment = "bu pin" },
            { text = "步频", comment = "bu pin" },
        },
        ["bu ping"] = {
            { text = "不平", comment = "bu ping" },
            { text = "不评", comment = "bu ping" },
            { text = "补平", comment = "bu ping" },
        },
        ["bu po"] = {
            { text = "不破", comment = "bu po" },
        },
        ["bu pu"] = {
            { text = "不铺", comment = "bu pu" },
            { text = "布朴", comment = "bu pu" },
        },
        ["bu qi"] = {
            { text = "不起", comment = "bu qi" },
            { text = "不气", comment = "bu qi" },
            { text = "补齐", comment = "bu qi" },
            { text = "不齐", comment = "bu qi" },
            { text = "补漆", comment = "bu qi" },
            { text = "补气", comment = "bu qi" },
            { text = "不骑", comment = "bu qi" },
            { text = "补起", comment = "bu qi" },
            { text = "不弃", comment = "bu qi" },
            { text = "不期", comment = "bu qi" },
            { text = "布奇", comment = "bu qi" },
            { text = "不器", comment = "bu qi" },
            { text = "不其", comment = "bu qi" },
        },
        ["bu qia"] = {
            { text = "不恰", comment = "bu qia" },
        },
        ["bu qian"] = {
            { text = "不签", comment = "bu qian" },
            { text = "补签", comment = "bu qian" },
            { text = "不欠", comment = "bu qian" },
            { text = "补钱", comment = "bu qian" },
            { text = "不浅", comment = "bu qian" },
            { text = "不前", comment = "bu qian" },
            { text = "逋欠", comment = "bu qian" },
        },
        ["bu qiang"] = {
            { text = "不强", comment = "bu qiang" },
            { text = "步枪", comment = "bu qiang" },
            { text = "不抢", comment = "bu qiang" },
            { text = "补强", comment = "bu qiang" },
            { text = "补枪", comment = "bu qiang" },
            { text = "补墙", comment = "bu qiang" },
        },
        ["bu qin"] = {
            { text = "不亲", comment = "bu qin" },
            { text = "不勤", comment = "bu qin" },
            { text = "不侵", comment = "bu qin" },
        },
        ["bu qing"] = {
            { text = "不请", comment = "bu qing" },
            { text = "不清", comment = "bu qing" },
            { text = "不轻", comment = "bu qing" },
            { text = "步青", comment = "bu qing" },
        },
        ["bu qiu"] = {
            { text = "不求", comment = "bu qiu" },
            { text = "补球", comment = "bu qiu" },
        },
        ["bu qu"] = {
            { text = "不去", comment = "bu qu" },
            { text = "不取", comment = "bu qu" },
            { text = "不屈", comment = "bu qu" },
            { text = "不娶", comment = "bu qu" },
            { text = "部曲", comment = "bu qu" },
        },
        ["bu quan"] = {
            { text = "不全", comment = "bu quan" },
            { text = "补全", comment = "bu quan" },
            { text = "不劝", comment = "bu quan" },
            { text = "补券", comment = "bu quan" },
        },
        ["bu qun"] = {
            { text = "布裙", comment = "bu qun" },
            { text = "不群", comment = "bu qun" },
        },
        ["bu ran"] = {
            { text = "不然", comment = "bu ran" },
            { text = "不染", comment = "bu ran" },
            { text = "不燃", comment = "bu ran" },
        },
        ["bu ran xing"] = {
            { text = "不燃性", comment = "bu ran xing" },
        },
        ["bu re"] = {
            { text = "不热", comment = "bu re" },
            { text = "不惹", comment = "bu re" },
        },
        ["bu ren"] = {
            { text = "不认", comment = "bu ren" },
            { text = "不忍", comment = "bu ren" },
            { text = "补人", comment = "bu ren" },
            { text = "不仁", comment = "bu ren" },
            { text = "不人", comment = "bu ren" },
            { text = "布仁", comment = "bu ren" },
        },
        ["bu ri"] = {
            { text = "不日", comment = "bu ri" },
        },
        ["bu rong"] = {
            { text = "不容", comment = "bu rong" },
            { text = "不溶", comment = "bu rong" },
            { text = "不融", comment = "bu rong" },
        },
        ["bu ru"] = {
            { text = "不如", comment = "bu ru" },
            { text = "步入", comment = "bu ru" },
            { text = "哺乳", comment = "bu ru" },
            { text = "不入", comment = "bu ru" },
            { text = "补入", comment = "bu ru" },
        },
        ["bu rui"] = {
            { text = "布瑞", comment = "bu rui" },
        },
        ["bu rui te"] = {
            { text = "布瑞特", comment = "bu rui te" },
        },
        ["bu ruo"] = {
            { text = "不弱", comment = "bu ruo" },
            { text = "不若", comment = "bu ruo" },
        },
        ["bu sa"] = {
            { text = "不撒", comment = "bu sa" },
        },
        ["bu sai"] = {
            { text = "不塞", comment = "bu sai" },
            { text = "补赛", comment = "bu sai" },
        },
        ["bu san"] = {
            { text = "不散", comment = "bu san" },
        },
        ["bu sang"] = {
            { text = "不丧", comment = "bu sang" },
        },
        ["bu sao"] = {
            { text = "不扫", comment = "bu sao" },
            { text = "不骚", comment = "bu sao" },
            { text = "补扫", comment = "bu sao" },
        },
        ["bu se"] = {
            { text = "补色", comment = "bu se" },
            { text = "不色", comment = "bu se" },
            { text = "布色", comment = "bu se" },
        },
        ["bu sen"] = {
            { text = "步森", comment = "bu sen" },
            { text = "堡森", comment = "bu sen" },
        },
        ["bu sha"] = {
            { text = "不杀", comment = "bu sha" },
            { text = "不傻", comment = "bu sha" },
            { text = "补啥", comment = "bu sha" },
            { text = "捕杀", comment = "bu sha" },
        },
        ["bu shan"] = {
            { text = "不删", comment = "bu shan" },
            { text = "不善", comment = "bu shan" },
            { text = "不闪", comment = "bu shan" },
            { text = "布山", comment = "bu shan" },
            { text = "布衫", comment = "bu shan" },
        },
        ["bu shang"] = {
            { text = "不上", comment = "bu shang" },
            { text = "补上", comment = "bu shang" },
            { text = "不伤", comment = "bu shang" },
            { text = "布上", comment = "bu shang" },
            { text = "补伤", comment = "bu shang" },
            { text = "埔上", comment = "bu shang" },
        },
        ["bu shao"] = {
            { text = "不少", comment = "bu shao" },
            { text = "不烧", comment = "bu shao" },
            { text = "步哨", comment = "bu shao" },
        },
        ["bu she"] = {
            { text = "不舍", comment = "bu she" },
            { text = "不设", comment = "bu she" },
            { text = "布设", comment = "bu she" },
            { text = "不射", comment = "bu she" },
            { text = "补射", comment = "bu she" },
        },
        ["bu shen"] = {
            { text = "不慎", comment = "bu shen" },
            { text = "不深", comment = "bu shen" },
            { text = "补肾", comment = "bu shen" },
            { text = "不审", comment = "bu shen" },
            { text = "不甚", comment = "bu shen" },
            { text = "不神", comment = "bu shen" },
            { text = "卜申", comment = "bu shen" },
            { text = "布什", comment = "bu shen" },
        },
        ["bu sheng"] = {
            { text = "不生", comment = "bu sheng" },
            { text = "不剩", comment = "bu sheng" },
            { text = "不升", comment = "bu sheng" },
            { text = "不胜", comment = "bu sheng" },
            { text = "不省", comment = "bu sheng" },
            { text = "补声", comment = "bu sheng" },
        },
        ["bu shi"] = {
            { text = "不是", comment = "bu shi" },
            { text = "不适", comment = "bu shi" },
            { text = "不时", comment = "bu shi" },
            { text = "部室", comment = "bu shi" },
            { text = "不实", comment = "bu shi" },
            { text = "不失", comment = "bu shi" },
            { text = "不试", comment = "bu shi" },
            { text = "捕食", comment = "bu shi" },
            { text = "不识", comment = "bu shi" },
            { text = "补时", comment = "bu shi" },
            { text = "不事", comment = "bu shi" },
            { text = "布施", comment = "bu shi" },
            { text = "不使", comment = "bu shi" },
            { text = "不食", comment = "bu shi" },
            { text = "布氏", comment = "bu shi" },
            { text = "补湿", comment = "bu shi" },
            { text = "卜筮", comment = "bu shi" },
            { text = "哺食", comment = "bu shi" },
        },
        ["bu shi da"] = {
            { text = "不是哒", comment = "bu shi da" },
        },
        ["bu shi ji"] = {
            { text = "不实际", comment = "bu shi ji" },
        },
        ["bu shu"] = {
            { text = "部署", comment = "bu shu" },
            { text = "步数", comment = "bu shu" },
            { text = "补数", comment = "bu shu" },
            { text = "不输", comment = "bu shu" },
            { text = "不属", comment = "bu shu" },
            { text = "部属", comment = "bu shu" },
            { text = "布书", comment = "bu shu" },
            { text = "捕鼠", comment = "bu shu" },
        },
        ["bu shu dan"] = {
            { text = "补数单", comment = "bu shu dan" },
        },
        ["bu shu ji"] = {
            { text = "捕鼠记", comment = "bu shu ji" },
        },
        ["bu shu shi"] = {
            { text = "不属实", comment = "bu shu shi" },
            { text = "不舒适", comment = "bu shu shi" },
        },
        ["bu shui"] = {
            { text = "不睡", comment = "bu shui" },
            { text = "补水", comment = "bu shui" },
            { text = "补税", comment = "bu shui" },
            { text = "不水", comment = "bu shui" },
        },
        ["bu shun"] = {
            { text = "不顺", comment = "bu shun" },
        },
        ["bu shuo"] = {
            { text = "不说", comment = "bu shuo" },
        },
        ["bu si"] = {
            { text = "不死", comment = "bu si" },
            { text = "不似", comment = "bu si" },
            { text = "不撕", comment = "bu si" },
            { text = "不思", comment = "bu si" },
            { text = "布斯", comment = "bu si" },
        },
        ["bu song"] = {
            { text = "不送", comment = "bu song" },
            { text = "不怂", comment = "bu song" },
            { text = "补送", comment = "bu song" },
            { text = "不松", comment = "bu song" },
        },
        ["bu sou"] = {
            { text = "不搜", comment = "bu sou" },
        },
        ["bu su"] = {
            { text = "不俗", comment = "bu su" },
            { text = "不素", comment = "bu su" },
            { text = "不速", comment = "bu su" },
        },
        ["bu sun"] = {
            { text = "不损", comment = "bu sun" },
            { text = "补损", comment = "bu sun" },
        },
        ["bu suo"] = {
            { text = "不锁", comment = "bu suo" },
            { text = "不缩", comment = "bu suo" },
        },
        ["bu ta"] = {
            { text = "不塌", comment = "bu ta" },
            { text = "布塔", comment = "bu ta" },
        },
        ["bu tai"] = {
            { text = "不太", comment = "bu tai" },
            { text = "补胎", comment = "bu tai" },
            { text = "步态", comment = "bu tai" },
            { text = "不抬", comment = "bu tai" },
            { text = "补台", comment = "bu tai" },
        },
        ["bu tang"] = {
            { text = "不烫", comment = "bu tang" },
            { text = "不躺", comment = "bu tang" },
            { text = "补汤", comment = "bu tang" },
        },
        ["bu tao"] = {
            { text = "布套", comment = "bu tao" },
            { text = "不套", comment = "bu tao" },
            { text = "不掏", comment = "bu tao" },
            { text = "不讨", comment = "bu tao" },
            { text = "逋逃", comment = "bu tao" },
        },
        ["bu te"] = {
            { text = "布特", comment = "bu te" },
            { text = "不特", comment = "bu te" },
        },
        ["bu teng"] = {
            { text = "不疼", comment = "bu teng" },
        },
        ["bu ti"] = {
            { text = "不提", comment = "bu ti" },
            { text = "补提", comment = "bu ti" },
            { text = "步梯", comment = "bu ti" },
            { text = "不踢", comment = "bu ti" },
            { text = "补体", comment = "bu ti" },
        },
        ["bu tian"] = {
            { text = "不填", comment = "bu tian" },
            { text = "不甜", comment = "bu tian" },
            { text = "补天", comment = "bu tian" },
            { text = "补填", comment = "bu tian" },
            { text = "不舔", comment = "bu tian" },
        },
        ["bu tiao"] = {
            { text = "不调", comment = "bu tiao" },
            { text = "不挑", comment = "bu tiao" },
            { text = "不跳", comment = "bu tiao" },
            { text = "布条", comment = "bu tiao" },
            { text = "补条", comment = "bu tiao" },
        },
        ["bu tie"] = {
            { text = "补贴", comment = "bu tie" },
            { text = "不贴", comment = "bu tie" },
            { text = "补铁", comment = "bu tie" },
            { text = "布贴", comment = "bu tie" },
        },
        ["bu ting"] = {
            { text = "不停", comment = "bu ting" },
            { text = "不听", comment = "bu ting" },
            { text = "不挺", comment = "bu ting" },
        },
        ["bu tong"] = {
            { text = "不同", comment = "bu tong" },
            { text = "不痛", comment = "bu tong" },
            { text = "不通", comment = "bu tong" },
            { text = "布同", comment = "bu tong" },
            { text = "布筒", comment = "bu tong" },
        },
        ["bu tu"] = {
            { text = "不吐", comment = "bu tu" },
            { text = "不图", comment = "bu tu" },
            { text = "不涂", comment = "bu tu" },
            { text = "补图", comment = "bu tu" },
            { text = "不土", comment = "bu tu" },
            { text = "补土", comment = "bu tu" },
            { text = "不秃", comment = "bu tu" },
            { text = "布图", comment = "bu tu" },
        },
        ["bu tuo"] = {
            { text = "不脱", comment = "bu tuo" },
            { text = "不妥", comment = "bu tuo" },
            { text = "不拖", comment = "bu tuo" },
            { text = "布拖", comment = "bu tuo" },
            { text = "布托", comment = "bu tuo" },
        },
        ["bu wai"] = {
            { text = "不歪", comment = "bu wai" },
            { text = "不外", comment = "bu wai" },
        },
        ["bu wan"] = {
            { text = "不玩", comment = "bu wan" },
            { text = "不晚", comment = "bu wan" },
            { text = "不完", comment = "bu wan" },
            { text = "补完", comment = "bu wan" },
            { text = "步婉", comment = "bu wan" },
            { text = "布万", comment = "bu wan" },
        },
        ["bu wang"] = {
            { text = "不忘", comment = "bu wang" },
            { text = "不往", comment = "bu wang" },
            { text = "不枉", comment = "bu wang" },
            { text = "不旺", comment = "bu wang" },
            { text = "布网", comment = "bu wang" },
        },
        ["bu wei"] = {
            { text = "不为", comment = "bu wei" },
            { text = "部位", comment = "bu wei" },
            { text = "补位", comment = "bu wei" },
            { text = "部委", comment = "bu wei" },
            { text = "不畏", comment = "bu wei" },
            { text = "不喂", comment = "bu wei" },
            { text = "不惟", comment = "bu wei" },
            { text = "不谓", comment = "bu wei" },
            { text = "哺喂", comment = "bu wei" },
            { text = "不韪", comment = "bu wei" },
        },
        ["bu wen"] = {
            { text = "不问", comment = "bu wen" },
            { text = "不稳", comment = "bu wen" },
            { text = "布纹", comment = "bu wen" },
            { text = "不闻", comment = "bu wen" },
            { text = "不紊", comment = "bu wen" },
            { text = "补纹", comment = "bu wen" },
        },
        ["bu wo"] = {
            { text = "补我", comment = "bu wo" },
            { text = "不我", comment = "bu wo" },
        },
        ["bu wu"] = {
            { text = "不误", comment = "bu wu" },
            { text = "不无", comment = "bu wu" },
            { text = "部务", comment = "bu wu" },
            { text = "不悟", comment = "bu wu" },
            { text = "部屋", comment = "bu wu" },
            { text = "步武", comment = "bu wu" },
            { text = "步舞", comment = "bu wu" },
        },
        ["bu xi"] = {
            { text = "补习", comment = "bu xi" },
            { text = "不洗", comment = "bu xi" },
            { text = "不惜", comment = "bu xi" },
            { text = "不息", comment = "bu xi" },
            { text = "不喜", comment = "bu xi" },
            { text = "不细", comment = "bu xi" },
            { text = "不吸", comment = "bu xi" },
            { text = "不系", comment = "bu xi" },
            { text = "步戏", comment = "bu xi" },
        },
        ["bu xi huan"] = {
            { text = "不喜欢", comment = "bu xi huan" },
        },
        ["bu xia"] = {
            { text = "不下", comment = "bu xia" },
            { text = "补下", comment = "bu xia" },
            { text = "不瞎", comment = "bu xia" },
            { text = "部下", comment = "bu xia" },
            { text = "布下", comment = "bu xia" },
            { text = "不暇", comment = "bu xia" },
        },
        ["bu xian"] = {
            { text = "不限", comment = "bu xian" },
            { text = "布线", comment = "bu xian" },
            { text = "不嫌", comment = "bu xian" },
            { text = "不闲", comment = "bu xian" },
            { text = "不显", comment = "bu xian" },
            { text = "不先", comment = "bu xian" },
            { text = "不咸", comment = "bu xian" },
            { text = "补线", comment = "bu xian" },
            { text = "不现", comment = "bu xian" },
        },
        ["bu xian sheng"] = {
            { text = "布先生", comment = "bu xian sheng" },
        },
        ["bu xiang"] = {
            { text = "不想", comment = "bu xiang" },
            { text = "不像", comment = "bu xiang" },
            { text = "不香", comment = "bu xiang" },
            { text = "不详", comment = "bu xiang" },
            { text = "不响", comment = "bu xiang" },
            { text = "不向", comment = "bu xiang" },
            { text = "不祥", comment = "bu xiang" },
            { text = "不相", comment = "bu xiang" },
            { text = "补项", comment = "bu xiang" },
            { text = "不象", comment = "bu xiang" },
        },
        ["bu xiang hua"] = {
            { text = "不像话", comment = "bu xiang hua" },
        },
        ["bu xiao"] = {
            { text = "不小", comment = "bu xiao" },
            { text = "不笑", comment = "bu xiao" },
            { text = "不消", comment = "bu xiao" },
            { text = "不孝", comment = "bu xiao" },
            { text = "不肖", comment = "bu xiao" },
            { text = "补校", comment = "bu xiao" },
        },
        ["bu xie"] = {
            { text = "不写", comment = "bu xie" },
            { text = "不谢", comment = "bu xie" },
            { text = "不懈", comment = "bu xie" },
            { text = "不屑", comment = "bu xie" },
            { text = "布鞋", comment = "bu xie" },
            { text = "补写", comment = "bu xie" },
            { text = "不歇", comment = "bu xie" },
            { text = "不卸", comment = "bu xie" },
        },
        ["bu xin"] = {
            { text = "不信", comment = "bu xin" },
            { text = "补芯", comment = "bu xin" },
            { text = "补锌", comment = "bu xin" },
            { text = "补心", comment = "bu xin" },
            { text = "不新", comment = "bu xin" },
            { text = "布心", comment = "bu xin" },
        },
        ["bu xing"] = {
            { text = "不行", comment = "bu xing" },
            { text = "步行", comment = "bu xing" },
            { text = "不幸", comment = "bu xing" },
            { text = "不醒", comment = "bu xing" },
            { text = "不兴", comment = "bu xing" },
            { text = "不姓", comment = "bu xing" },
            { text = "补星", comment = "bu xing" },
            { text = "布星", comment = "bu xing" },
        },
        ["bu xiu"] = {
            { text = "补休", comment = "bu xiu" },
            { text = "不休", comment = "bu xiu" },
            { text = "不修", comment = "bu xiu" },
            { text = "不朽", comment = "bu xiu" },
            { text = "不锈", comment = "bu xiu" },
            { text = "补修", comment = "bu xiu" },
        },
        ["bu xu"] = {
            { text = "不许", comment = "bu xu" },
            { text = "不需", comment = "bu xu" },
            { text = "不虚", comment = "bu xu" },
            { text = "不续", comment = "bu xu" },
            { text = "不须", comment = "bu xu" },
            { text = "补虚", comment = "bu xu" },
            { text = "步序", comment = "bu xu" },
            { text = "不恤", comment = "bu xu" },
        },
        ["bu xuan"] = {
            { text = "不选", comment = "bu xuan" },
            { text = "补选", comment = "bu xuan" },
            { text = "不宣", comment = "bu xuan" },
        },
        ["bu xue"] = {
            { text = "不学", comment = "bu xue" },
            { text = "补血", comment = "bu xue" },
            { text = "不削", comment = "bu xue" },
            { text = "补学", comment = "bu xue" },
        },
        ["bu xun"] = {
            { text = "不逊", comment = "bu xun" },
            { text = "补训", comment = "bu xun" },
            { text = "步巡", comment = "bu xun" },
        },
        ["bu ya"] = {
            { text = "不雅", comment = "bu ya" },
            { text = "补牙", comment = "bu ya" },
            { text = "不压", comment = "bu ya" },
            { text = "不呀", comment = "bu ya" },
            { text = "补压", comment = "bu ya" },
        },
        ["bu yan"] = {
            { text = "不严", comment = "bu yan" },
            { text = "不演", comment = "bu yan" },
            { text = "不言", comment = "bu yan" },
            { text = "不厌", comment = "bu yan" },
            { text = "不验", comment = "bu yan" },
        },
        ["bu yang"] = {
            { text = "不养", comment = "bu yang" },
            { text = "不痒", comment = "bu yang" },
            { text = "布样", comment = "bu yang" },
            { text = "步阳", comment = "bu yang" },
            { text = "补养", comment = "bu yang" },
            { text = "补阳", comment = "bu yang" },
            { text = "不扬", comment = "bu yang" },
            { text = "哺养", comment = "bu yang" },
        },
        ["bu yang le"] = {
            { text = "不养了", comment = "bu yang le" },
        },
        ["bu yao"] = {
            { text = "不要", comment = "bu yao" },
            { text = "补药", comment = "bu yao" },
            { text = "不摇", comment = "bu yao" },
            { text = "不咬", comment = "bu yao" },
            { text = "不药", comment = "bu yao" },
            { text = "步摇", comment = "bu yao" },
        },
        ["bu yao qu"] = {
            { text = "不要去", comment = "bu yao qu" },
        },
        ["bu ye"] = {
            { text = "不也", comment = "bu ye" },
            { text = "补液", comment = "bu ye" },
            { text = "布业", comment = "bu ye" },
            { text = "不野", comment = "bu ye" },
            { text = "不夜", comment = "bu ye" },
        },
        ["bu yi"] = {
            { text = "不易", comment = "bu yi" },
            { text = "不一", comment = "bu yi" },
            { text = "不宜", comment = "bu yi" },
            { text = "布艺", comment = "bu yi" },
            { text = "不以", comment = "bu yi" },
            { text = "不已", comment = "bu yi" },
            { text = "不移", comment = "bu yi" },
            { text = "布衣", comment = "bu yi" },
            { text = "补遗", comment = "bu yi" },
            { text = "不义", comment = "bu yi" },
            { text = "布依", comment = "bu yi" },
            { text = "不疑", comment = "bu yi" },
            { text = "补益", comment = "bu yi" },
            { text = "不依", comment = "bu yi" },
            { text = "不亦", comment = "bu yi" },
            { text = "不意", comment = "bu yi" },
            { text = "卜弋", comment = "bu yi" },
        },
        ["bu yin"] = {
            { text = "不因", comment = "bu yin" },
            { text = "不印", comment = "bu yin" },
            { text = "补印", comment = "bu yin" },
            { text = "不饮", comment = "bu yin" },
        },
        ["bu ying"] = {
            { text = "不应", comment = "bu ying" },
            { text = "不赢", comment = "bu ying" },
            { text = "不硬", comment = "bu ying" },
        },
        ["bu yong"] = {
            { text = "不用", comment = "bu yong" },
            { text = "步涌", comment = "bu yong" },
        },
        ["bu you"] = {
            { text = "不有", comment = "bu you" },
            { text = "不由", comment = "bu you" },
            { text = "不油", comment = "bu you" },
            { text = "补油", comment = "bu you" },
            { text = "补邮", comment = "bu you" },
        },
        ["bu yu"] = {
            { text = "不予", comment = "bu yu" },
            { text = "捕鱼", comment = "bu yu" },
            { text = "不与", comment = "bu yu" },
            { text = "不语", comment = "bu yu" },
            { text = "不遇", comment = "bu yu" },
            { text = "不育", comment = "bu yu" },
            { text = "哺育", comment = "bu yu" },
            { text = "不渝", comment = "bu yu" },
            { text = "补语", comment = "bu yu" },
            { text = "不欲", comment = "bu yu" },
            { text = "布雨", comment = "bu yu" },
            { text = "不愈", comment = "bu yu" },
            { text = "不虞", comment = "bu yu" },
        },
        ["bu yuan"] = {
            { text = "不远", comment = "bu yuan" },
            { text = "不愿", comment = "bu yuan" },
            { text = "部员", comment = "bu yuan" },
            { text = "不圆", comment = "bu yuan" },
            { text = "不怨", comment = "bu yuan" },
            { text = "补员", comment = "bu yuan" },
            { text = "不冤", comment = "bu yuan" },
        },
        ["bu yuan qu"] = {
            { text = "不愿去", comment = "bu yuan qu" },
        },
        ["bu yue"] = {
            { text = "不约", comment = "bu yue" },
            { text = "不悦", comment = "bu yue" },
            { text = "捕月", comment = "bu yue" },
            { text = "补约", comment = "bu yue" },
            { text = "步月", comment = "bu yue" },
        },
        ["bu yun"] = {
            { text = "不孕", comment = "bu yun" },
            { text = "不晕", comment = "bu yun" },
            { text = "不匀", comment = "bu yun" },
            { text = "步云", comment = "bu yun" },
            { text = "不允", comment = "bu yun" },
            { text = "步韵", comment = "bu yun" },
        },
        ["bu zai"] = {
            { text = "不在", comment = "bu zai" },
            { text = "不再", comment = "bu zai" },
            { text = "补在", comment = "bu zai" },
            { text = "补栽", comment = "bu zai" },
        },
        ["bu zan"] = {
            { text = "不攒", comment = "bu zan" },
            { text = "不赞", comment = "bu zan" },
            { text = "补赞", comment = "bu zan" },
        },
        ["bu ze"] = {
            { text = "不择", comment = "bu ze" },
        },
        ["bu zhai"] = {
            { text = "不摘", comment = "bu zhai" },
        },
        ["bu zhan"] = {
            { text = "不占", comment = "bu zhan" },
            { text = "布展", comment = "bu zhan" },
            { text = "不沾", comment = "bu zhan" },
            { text = "不站", comment = "bu zhan" },
            { text = "步战", comment = "bu zhan" },
            { text = "不粘", comment = "bu zhan" },
        },
        ["bu zhang"] = {
            { text = "部长", comment = "bu zhang" },
            { text = "不涨", comment = "bu zhang" },
            { text = "补涨", comment = "bu zhang" },
            { text = "补账", comment = "bu zhang" },
            { text = "补张", comment = "bu zhang" },
            { text = "补章", comment = "bu zhang" },
            { text = "补帐", comment = "bu zhang" },
        },
        ["bu zhe"] = {
            { text = "不折", comment = "bu zhe" },
            { text = "补着", comment = "bu zhe" },
        },
        ["bu zhen"] = {
            { text = "布阵", comment = "bu zhen" },
            { text = "不振", comment = "bu zhen" },
            { text = "不真", comment = "bu zhen" },
            { text = "补针", comment = "bu zhen" },
            { text = "补帧", comment = "bu zhen" },
        },
        ["bu zheng"] = {
            { text = "不正", comment = "bu zheng" },
            { text = "不整", comment = "bu zheng" },
            { text = "补正", comment = "bu zheng" },
            { text = "不争", comment = "bu zheng" },
            { text = "不挣", comment = "bu zheng" },
            { text = "补证", comment = "bu zheng" },
            { text = "补征", comment = "bu zheng" },
            { text = "布政", comment = "bu zheng" },
        },
        ["bu zhi"] = {
            { text = "不知", comment = "bu zhi" },
            { text = "不止", comment = "bu zhi" },
            { text = "布置", comment = "bu zhi" },
            { text = "不值", comment = "bu zhi" },
            { text = "不只", comment = "bu zhi" },
            { text = "不直", comment = "bu zhi" },
            { text = "不治", comment = "bu zhi" },
            { text = "补植", comment = "bu zhi" },
            { text = "不支", comment = "bu zhi" },
            { text = "不至", comment = "bu zhi" },
            { text = "不致", comment = "bu zhi" },
            { text = "补制", comment = "bu zhi" },
            { text = "步骘", comment = "bu zhi" },
            { text = "步知", comment = "bu zhi" },
            { text = "不置", comment = "bu zhi" },
        },
        ["bu zhi dao"] = {
            { text = "不知道", comment = "bu zhi dao" },
        },
        ["bu zhi shi"] = {
            { text = "不只是", comment = "bu zhi shi" },
        },
        ["bu zhong"] = {
            { text = "不中", comment = "bu zhong" },
            { text = "不重", comment = "bu zhong" },
            { text = "补种", comment = "bu zhong" },
            { text = "不种", comment = "bu zhong" },
            { text = "不忠", comment = "bu zhong" },
            { text = "不肿", comment = "bu zhong" },
            { text = "布种", comment = "bu zhong" },
            { text = "补钟", comment = "bu zhong" },
            { text = "补中", comment = "bu zhong" },
        },
        ["bu zhou"] = {
            { text = "步骤", comment = "bu zhou" },
            { text = "不周", comment = "bu zhou" },
        },
        ["bu zhu"] = {
            { text = "不住", comment = "bu zhu" },
            { text = "补助", comment = "bu zhu" },
            { text = "不煮", comment = "bu zhu" },
            { text = "不著", comment = "bu zhu" },
        },
        ["bu zhu ren"] = {
            { text = "部主任", comment = "bu zhu ren" },
        },
        ["bu zhuang"] = {
            { text = "不装", comment = "bu zhuang" },
            { text = "补妆", comment = "bu zhuang" },
            { text = "不撞", comment = "bu zhuang" },
            { text = "补装", comment = "bu zhuang" },
            { text = "补桩", comment = "bu zhuang" },
            { text = "部装", comment = "bu zhuang" },
            { text = "布桩", comment = "bu zhuang" },
            { text = "布庄", comment = "bu zhuang" },
            { text = "卜庄", comment = "bu zhuang" },
        },
        ["bu zhuo"] = {
            { text = "捕捉", comment = "bu zhuo" },
        },
        ["bu zi"] = {
            { text = "步子", comment = "bu zi" },
            { text = "堡子", comment = "bu zi" },
            { text = "布子", comment = "bu zi" },
            { text = "簿子", comment = "bu zi" },
            { text = "补子", comment = "bu zi" },
            { text = "埠子", comment = "bu zi" },
            { text = "不子", comment = "bu zi" },
            { text = "不赀", comment = "bu zi" },
            { text = "餔子", comment = "bu zi" },
        },
        ["bu zong"] = {
            { text = "不总", comment = "bu zong" },
            { text = "卜总", comment = "bu zong" },
            { text = "步总", comment = "bu zong" },
        },
        ["bu zu"] = {
            { text = "不足", comment = "bu zu" },
            { text = "补足", comment = "bu zu" },
            { text = "不租", comment = "bu zu" },
            { text = "不组", comment = "bu zu" },
            { text = "部族", comment = "bu zu" },
            { text = "部组", comment = "bu zu" },
            { text = "补租", comment = "bu zu" },
            { text = "埔租", comment = "bu zu" },
        },
        ["bu zuo"] = {
            { text = "不做", comment = "bu zuo" },
            { text = "不坐", comment = "bu zuo" },
            { text = "不作", comment = "bu zuo" },
            { text = "补做", comment = "bu zuo" },
        },
        ["ca ban"] = {
            { text = "擦板", comment = "ca ban" },
        },
        ["ca bei"] = {
            { text = "擦背", comment = "ca bei" },
        },
        ["ca tou"] = {
            { text = "擦头", comment = "ca tou" },
        },
        ["ca yin"] = {
            { text = "擦音", comment = "ca yin" },
        },
        ["ca you"] = {
            { text = "擦油", comment = "ca you" },
        },
        ["cai bu"] = {
            { text = "才不", comment = "cai bu" },
            { text = "裁布", comment = "cai bu" },
            { text = "蔡部", comment = "cai bu" },
            { text = "财补", comment = "cai bu" },
            { text = "彩布", comment = "cai bu" },
            { text = "财布", comment = "cai bu" },
        },
        ["cai ou"] = {
            { text = "才欧", comment = "cai ou" },
        },
        ["cai yu"] = {
            { text = "彩玉", comment = "cai yu" },
            { text = "采育", comment = "cai yu" },
            { text = "蔡玉", comment = "cai yu" },
            { text = "蔡宇", comment = "cai yu" },
            { text = "财鱼", comment = "cai yu" },
            { text = "蔡雨", comment = "cai yu" },
            { text = "蔡瑜", comment = "cai yu" },
            { text = "彩羽", comment = "cai yu" },
            { text = "菜鱼", comment = "cai yu" },
        },
        ["cang bu"] = {
            { text = "仓埠", comment = "cang bu" },
        },
        ["cao an"] = {
            { text = "草案", comment = "cao an" },
            { text = "曹安", comment = "cao an" },
        },
        ["cao di"] = {
            { text = "草地", comment = "cao di" },
            { text = "槽底", comment = "cao di" },
            { text = "曹迪", comment = "cao di" },
        },
        ["ce hua an"] = {
            { text = "策划案", comment = "ce hua an" },
        },
        ["ce ran"] = {
            { text = "恻然", comment = "ce ran" },
        },
        ["ce tai"] = {
            { text = "策太", comment = "ce tai" },
            { text = "侧台", comment = "ce tai" },
        },
        ["ce tou"] = {
            { text = "侧头", comment = "ce tou" },
            { text = "测头", comment = "ce tou" },
            { text = "侧透", comment = "ce tou" },
        },
        ["ceng ai"] = {
            { text = "曾爱", comment = "ceng ai" },
        },
        ["ceng bu"] = {
            { text = "曾部", comment = "ceng bu" },
        },
        ["cha bai"] = {
            { text = "查摆", comment = "cha bai" },
            { text = "查白", comment = "cha bai" },
            { text = "茶百", comment = "cha bai" },
        },
        ["cha ban"] = {
            { text = "插板", comment = "cha ban" },
            { text = "插班", comment = "cha ban" },
            { text = "查办", comment = "cha ban" },
            { text = "叉板", comment = "cha ban" },
            { text = "查班", comment = "cha ban" },
            { text = "差班", comment = "cha ban" },
        },
        ["cha ban xian"] = {
            { text = "插板线", comment = "cha ban xian" },
        },
        ["cha bei"] = {
            { text = "茶杯", comment = "cha bei" },
            { text = "差辈", comment = "cha bei" },
            { text = "察北", comment = "cha bei" },
        },
        ["cha bei jia"] = {
            { text = "茶杯架", comment = "cha bei jia" },
        },
        ["cha bie"] = {
            { text = "差别", comment = "cha bie" },
        },
        ["cha bu"] = {
            { text = "差不", comment = "cha bu" },
            { text = "查不", comment = "cha bu" },
            { text = "插补", comment = "cha bu" },
            { text = "查补", comment = "cha bu" },
            { text = "察布", comment = "cha bu" },
            { text = "查布", comment = "cha bu" },
        },
        ["cha nin"] = {
            { text = "差您", comment = "cha nin" },
        },
        ["cha ou"] = {
            { text = "茶瓯", comment = "cha ou" },
        },
        ["cha ta"] = {
            { text = "查他", comment = "cha ta" },
            { text = "插她", comment = "cha ta" },
        },
        ["cha tai"] = {
            { text = "茶台", comment = "cha tai" },
            { text = "茶太", comment = "cha tai" },
        },
        ["cha tan"] = {
            { text = "查探", comment = "cha tan" },
            { text = "茶摊", comment = "cha tan" },
        },
        ["cha tao"] = {
            { text = "插套", comment = "cha tao" },
        },
        ["cha te"] = {
            { text = "查特", comment = "cha te" },
        },
        ["cha tou"] = {
            { text = "插头", comment = "cha tou" },
            { text = "差头", comment = "cha tou" },
            { text = "叉头", comment = "cha tou" },
            { text = "茶头", comment = "cha tou" },
            { text = "槎头", comment = "cha tou" },
            { text = "岔头", comment = "cha tou" },
        },
        ["cha tou liao"] = {
            { text = "插头料", comment = "cha tou liao" },
        },
        ["cha tuo"] = {
            { text = "茶托", comment = "cha tuo" },
        },
        ["cha yan"] = {
            { text = "查验", comment = "cha yan" },
            { text = "插眼", comment = "cha yan" },
            { text = "茶颜", comment = "cha yan" },
            { text = "茶烟", comment = "cha yan" },
            { text = "察验", comment = "cha yan" },
            { text = "岔眼", comment = "cha yan" },
            { text = "插言", comment = "cha yan" },
        },
        ["cha yi bu"] = {
            { text = "差一步", comment = "cha yi bu" },
        },
        ["cha yin"] = {
            { text = "茶饮", comment = "cha yin" },
            { text = "查因", comment = "cha yin" },
        },
        ["cha you"] = {
            { text = "茶油", comment = "cha you" },
            { text = "茶友", comment = "cha you" },
            { text = "察右", comment = "cha you" },
        },
        ["cha yuan"] = {
            { text = "茶园", comment = "cha yuan" },
            { text = "差远", comment = "cha yuan" },
            { text = "茶苑", comment = "cha yuan" },
            { text = "茶缘", comment = "cha yuan" },
            { text = "茶院", comment = "cha yuan" },
        },
        ["chai an"] = {
            { text = "拆安", comment = "chai an" },
            { text = "拆案", comment = "chai an" },
        },
        ["chai bu"] = {
            { text = "差补", comment = "chai bu" },
        },
        ["chai xu"] = {
            { text = "柴旭", comment = "chai xu" },
        },
        ["chai you"] = {
            { text = "柴油", comment = "chai you" },
        },
        ["chai yu"] = {
            { text = "柴玉", comment = "chai yu" },
            { text = "柴鱼", comment = "chai yu" },
        },
        ["chan yu"] = {
            { text = "产于", comment = "chan yu" },
            { text = "单于", comment = "chan yu" },
            { text = "禅语", comment = "chan yu" },
            { text = "谄谀", comment = "chan yu" },
            { text = "襜褕", comment = "chan yu" },
        },
        ["chang a"] = {
            { text = "长啊", comment = "chang a" },
        },
        ["chang ai"] = {
            { text = "肠癌", comment = "chang ai" },
        },
        ["chang an"] = {
            { text = "长安", comment = "chang an" },
            { text = "长按", comment = "chang an" },
            { text = "常安", comment = "chang an" },
            { text = "昌安", comment = "chang an" },
            { text = "畅安", comment = "chang an" },
            { text = "常暗", comment = "chang an" },
        },
        ["chang ao"] = {
            { text = "长袄", comment = "chang ao" },
        },
        ["chang bu"] = {
            { text = "厂部", comment = "chang bu" },
            { text = "场布", comment = "chang bu" },
            { text = "场部", comment = "chang bu" },
            { text = "长不", comment = "chang bu" },
            { text = "长布", comment = "chang bu" },
            { text = "长补", comment = "chang bu" },
        },
        ["chang bu liao"] = {
            { text = "唱不了", comment = "chang bu liao" },
        },
        ["chang e"] = {
            { text = "嫦娥", comment = "chang e" },
            { text = "常娥", comment = "chang e" },
        },
        ["chang huai"] = {
            { text = "常怀", comment = "chang huai" },
            { text = "长淮", comment = "chang huai" },
            { text = "畅怀", comment = "chang huai" },
            { text = "敞怀", comment = "chang huai" },
        },
        ["chang ou"] = {
            { text = "常鸥", comment = "chang ou" },
        },
        ["chang ri"] = {
            { text = "常日", comment = "chang ri" },
            { text = "长日", comment = "chang ri" },
        },
        ["chang wo"] = {
            { text = "唱我", comment = "chang wo" },
        },
        ["chao ai"] = {
            { text = "超爱", comment = "chao ai" },
        },
        ["chao an"] = {
            { text = "潮安", comment = "chao an" },
            { text = "朝安", comment = "chao an" },
        },
        ["chao an xian"] = {
            { text = "潮安县", comment = "chao an xian" },
        },
        ["chao bu"] = {
            { text = "抄不", comment = "chao bu" },
            { text = "超补", comment = "chao bu" },
        },
        ["chao di"] = {
            { text = "抄底", comment = "chao di" },
            { text = "超低", comment = "chao di" },
            { text = "超弟", comment = "chao di" },
            { text = "超迪", comment = "chao di" },
        },
        ["chao di jia"] = {
            { text = "超低价", comment = "chao di jia" },
            { text = "抄底价", comment = "chao di jia" },
        },
        ["chao ou"] = {
            { text = "炒藕", comment = "chao ou" },
        },
        ["chao ye"] = {
            { text = "超爷", comment = "chao ye" },
            { text = "朝野", comment = "chao ye" },
            { text = "超业", comment = "chao ye" },
        },
        ["che nei"] = {
            { text = "车内", comment = "che nei" },
        },
        ["che niu"] = {
            { text = "车牛", comment = "che niu" },
        },
        ["che tai"] = {
            { text = "车胎", comment = "che tai" },
            { text = "车台", comment = "che tai" },
            { text = "撤台", comment = "che tai" },
        },
        ["che tan"] = {
            { text = "扯谈", comment = "che tan" },
            { text = "车坛", comment = "che tan" },
        },
        ["che tao"] = {
            { text = "车套", comment = "che tao" },
        },
        ["che tie"] = {
            { text = "车贴", comment = "che tie" },
        },
        ["che tou"] = {
            { text = "车头", comment = "che tou" },
        },
        ["che tuan"] = {
            { text = "车团", comment = "che tuan" },
        },
        ["che tuo"] = {
            { text = "车托", comment = "che tuo" },
        },
        ["chen bu"] = {
            { text = "衬布", comment = "chen bu" },
            { text = "陈部", comment = "chen bu" },
            { text = "陈埠", comment = "chen bu" },
        },
        ["chen di"] = {
            { text = "沉底", comment = "chen di" },
            { text = "陈迪", comment = "chen di" },
            { text = "衬底", comment = "chen di" },
            { text = "陈娣", comment = "chen di" },
            { text = "陈笛", comment = "chen di" },
        },
        ["chen huai"] = {
            { text = "陈怀", comment = "chen huai" },
        },
        ["chen jia nan"] = {
            { text = "陈佳楠", comment = "chen jia nan" },
        },
        ["chen jian an"] = {
            { text = "陈建安", comment = "chen jian an" },
        },
        ["chen ou"] = {
            { text = "陈欧", comment = "chen ou" },
        },
        ["chen ri"] = {
            { text = "陈日", comment = "chen ri" },
            { text = "沉日", comment = "chen ri" },
        },
        ["chen yu"] = {
            { text = "陈宇", comment = "chen yu" },
            { text = "陈玉", comment = "chen yu" },
            { text = "陈雨", comment = "chen yu" },
            { text = "陈瑜", comment = "chen yu" },
            { text = "晨宇", comment = "chen yu" },
            { text = "陈煜", comment = "chen yu" },
            { text = "陈钰", comment = "chen yu" },
            { text = "辰宇", comment = "chen yu" },
            { text = "沉郁", comment = "chen yu" },
            { text = "晨雨", comment = "chen yu" },
            { text = "陈羽", comment = "chen yu" },
            { text = "宸宇", comment = "chen yu" },
            { text = "陈昱", comment = "chen yu" },
            { text = "沉鱼", comment = "chen yu" },
            { text = "陈禹", comment = "chen yu" },
            { text = "陈渝", comment = "chen yu" },
            { text = "陈余", comment = "chen yu" },
            { text = "陈裕", comment = "chen yu" },
            { text = "陈育", comment = "chen yu" },
            { text = "陈郁", comment = "chen yu" },
            { text = "陈语", comment = "chen yu" },
            { text = "陈屿", comment = "chen yu" },
            { text = "晨语", comment = "chen yu" },
            { text = "陈彧", comment = "chen yu" },
            { text = "陈毓", comment = "chen yu" },
            { text = "陈妤", comment = "chen yu" },
            { text = "辰雨", comment = "chen yu" },
            { text = "陈俞", comment = "chen yu" },
            { text = "谶语", comment = "chen yu" },
            { text = "陈于", comment = "chen yu" },
            { text = "陈鱼", comment = "chen yu" },
        },
        ["cheng ai"] = {
            { text = "成爱", comment = "cheng ai" },
            { text = "惩艾", comment = "cheng ai" },
        },
        ["cheng an"] = {
            { text = "成安", comment = "cheng an" },
            { text = "诚安", comment = "cheng an" },
            { text = "城安", comment = "cheng an" },
            { text = "承安", comment = "cheng an" },
            { text = "成案", comment = "cheng an" },
            { text = "程安", comment = "cheng an" },
        },
        ["cheng bu"] = {
            { text = "成不", comment = "cheng bu" },
            { text = "城步", comment = "cheng bu" },
            { text = "程部", comment = "cheng bu" },
        },
        ["cheng fo"] = {
            { text = "成佛", comment = "cheng fo" },
        },
        ["cheng huai"] = {
            { text = "撑坏", comment = "cheng huai" },
            { text = "骋怀", comment = "cheng huai" },
        },
        ["cheng ri"] = {
            { text = "成日", comment = "cheng ri" },
        },
        ["cheng wo"] = {
            { text = "成我", comment = "cheng wo" },
        },
        ["cheng xu"] = {
            { text = "程序", comment = "cheng xu" },
            { text = "程旭", comment = "cheng xu" },
            { text = "成旭", comment = "cheng xu" },
            { text = "称许", comment = "cheng xu" },
            { text = "诚旭", comment = "cheng xu" },
            { text = "乘虚", comment = "cheng xu" },
        },
        ["cheng ye"] = {
            { text = "成业", comment = "cheng ye" },
            { text = "城野", comment = "cheng ye" },
            { text = "诚业", comment = "cheng ye" },
            { text = "程野", comment = "cheng ye" },
            { text = "程烨", comment = "cheng ye" },
            { text = "程业", comment = "cheng ye" },
            { text = "成夜", comment = "cheng ye" },
            { text = "晟业", comment = "cheng ye" },
        },
        ["chi bu"] = {
            { text = "吃不", comment = "chi bu" },
        },
        ["chi ou"] = {
            { text = "吃藕", comment = "chi ou" },
        },
        ["chong huai"] = {
            { text = "宠坏", comment = "chong huai" },
        },
        ["chong ri"] = {
            { text = "冲日", comment = "chong ri" },
        },
        ["chou huai"] = {
            { text = "愁怀", comment = "chou huai" },
        },
        ["chou ri"] = {
            { text = "仇日", comment = "chou ri" },
            { text = "畴日", comment = "chou ri" },
        },
        ["chu huai"] = {
            { text = "楚怀", comment = "chu huai" },
        },
        ["chu nai"] = {
            { text = "出奶", comment = "chu nai" },
        },
        ["chu nan"] = {
            { text = "处男", comment = "chu nan" },
            { text = "楚南", comment = "chu nan" },
        },
        ["chu ne"] = {
            { text = "处呢", comment = "chu ne" },
        },
        ["chu nei"] = {
            { text = "处内", comment = "chu nei" },
        },
        ["chu niu"] = {
            { text = "出牛", comment = "chu niu" },
        },
        ["chu ri"] = {
            { text = "初日", comment = "chu ri" },
            { text = "除日", comment = "chu ri" },
        },
        ["chu xu e"] = {
            { text = "储蓄额", comment = "chu xu e" },
        },
        ["chu xue"] = {
            { text = "初学", comment = "chu xue" },
            { text = "初雪", comment = "chu xue" },
            { text = "除雪", comment = "chu xue" },
        },
        ["chu you"] = {
            { text = "出游", comment = "chu you" },
            { text = "出油", comment = "chu you" },
            { text = "除油", comment = "chu you" },
            { text = "储油", comment = "chu you" },
            { text = "出有", comment = "chu you" },
            { text = "处有", comment = "chu you" },
        },
        ["chu yuan"] = {
            { text = "出院", comment = "chu yuan" },
            { text = "初元", comment = "chu yuan" },
            { text = "楚源", comment = "chu yuan" },
            { text = "楚元", comment = "chu yuan" },
            { text = "初原", comment = "chu yuan" },
            { text = "初愿", comment = "chu yuan" },
            { text = "楚原", comment = "chu yuan" },
        },
        ["chui bu"] = {
            { text = "吹不", comment = "chui bu" },
        },
        ["chui xu"] = {
            { text = "吹嘘", comment = "chui xu" },
        },
        ["chun ai"] = {
            { text = "纯爱", comment = "chun ai" },
        },
        ["chun an"] = {
            { text = "淳安", comment = "chun an" },
            { text = "春安", comment = "chun an" },
        },
        ["chun di"] = {
            { text = "纯涤", comment = "chun di" },
            { text = "春娣", comment = "chun di" },
        },
        ["chun e"] = {
            { text = "春娥", comment = "chun e" },
        },
        ["chun yu"] = {
            { text = "春雨", comment = "chun yu" },
            { text = "春宇", comment = "chun yu" },
            { text = "纯欲", comment = "chun yu" },
            { text = "唇语", comment = "chun yu" },
            { text = "春玉", comment = "chun yu" },
            { text = "淳于", comment = "chun yu" },
            { text = "春羽", comment = "chun yu" },
            { text = "春语", comment = "chun yu" },
            { text = "錞于", comment = "chun yu" },
        },
        ["ci bu"] = {
            { text = "次布", comment = "ci bu" },
            { text = "疵布", comment = "ci bu" },
        },
        ["ci huai"] = {
            { text = "刺槐", comment = "ci huai" },
        },
        ["ci ou"] = {
            { text = "瓷偶", comment = "ci ou" },
        },
        ["ci ri"] = {
            { text = "次日", comment = "ci ri" },
        },
        ["cu bei"] = {
            { text = "醋北", comment = "cu bei" },
        },
        ["cu yan"] = {
            { text = "粗盐", comment = "cu yan" },
            { text = "促炎", comment = "cu yan" },
        },
        ["cu yao"] = {
            { text = "粗腰", comment = "cu yao" },
        },
        ["cu ye"] = {
            { text = "粗野", comment = "cu ye" },
            { text = "醋业", comment = "cu ye" },
        },
        ["cu yin"] = {
            { text = "促音", comment = "cu yin" },
        },
        ["cu yuan"] = {
            { text = "粗圆", comment = "cu yuan" },
            { text = "粗圆", comment = "cu yuan" },
        },
        ["cui an"] = {
            { text = "崔安", comment = "cui an" },
        },
        ["cui ao"] = {
            { text = "崔傲", comment = "cui ao" },
        },
        ["cui bu"] = {
            { text = "崔部", comment = "cui bu" },
        },
        ["cui e"] = {
            { text = "翠娥", comment = "cui e" },
        },
        ["cui fo"] = {
            { text = "崔佛", comment = "cui fo" },
        },
        ["cui ou"] = {
            { text = "脆藕", comment = "cui ou" },
            { text = "脆藕", comment = "cui ou" },
        },
        ["cui xu"] = {
            { text = "崔旭", comment = "cui xu" },
        },
        ["cui yu"] = {
            { text = "翠玉", comment = "cui yu" },
            { text = "崔宇", comment = "cui yu" },
            { text = "崔玉", comment = "cui yu" },
            { text = "脆鱼", comment = "cui yu" },
            { text = "崔雨", comment = "cui yu" },
            { text = "崔钰", comment = "cui yu" },
        },
        ["cuo di"] = {
            { text = "错地", comment = "cuo di" },
        },
        ["da"] = {
            { text = "大", comment = "da" },
            { text = "打", comment = "da" },
            { text = "达", comment = "da" },
            { text = "答", comment = "da" },
            { text = "搭", comment = "da" },
            { text = "哒", comment = "da" },
            { text = "嗒", comment = "da" },
            { text = "妲", comment = "da" },
            { text = "沓", comment = "da" },
            { text = "耷", comment = "da" },
            { text = "笪", comment = "da" },
            { text = "跶", comment = "da" },
            { text = "怛", comment = "da" },
            { text = "瘩", comment = "da" },
            { text = "鞑", comment = "da" },
            { text = "荙", comment = "da" },
            { text = "褡", comment = "da" },
            { text = "炟", comment = "da" },
            { text = "靼", comment = "da" },
            { text = "垯", comment = "da" },
            { text = "溚", comment = "da" },
            { text = "疸", comment = "da" },
            { text = "鿎", comment = "da" },
            { text = "𨱏", comment = "da" },
            { text = "𫟼", comment = "da" },
        },
        ["da a"] = {
            { text = "打啊", comment = "da a" },
            { text = "大啊", comment = "da a" },
            { text = "大阿", comment = "da a" },
        },
        ["da an"] = {
            { text = "答案", comment = "da an" },
            { text = "大安", comment = "da an" },
            { text = "大案", comment = "da an" },
            { text = "达安", comment = "da an" },
            { text = "大岸", comment = "da an" },
            { text = "荅案", comment = "da an" },
        },
        ["da ao"] = {
            { text = "大奥", comment = "da ao" },
            { text = "大袄", comment = "da ao" },
            { text = "大鳌", comment = "da ao" },
            { text = "大澳", comment = "da ao" },
        },
        ["da ao si"] = {
            { text = "达奥斯", comment = "da ao si" },
        },
        ["da ba"] = {
            { text = "打吧", comment = "da ba" },
            { text = "大把", comment = "da ba" },
            { text = "大巴", comment = "da ba" },
            { text = "大坝", comment = "da ba" },
            { text = "打把", comment = "da ba" },
            { text = "打靶", comment = "da ba" },
            { text = "大吧", comment = "da ba" },
            { text = "大爸", comment = "da ba" },
            { text = "大八", comment = "da ba" },
            { text = "达巴", comment = "da ba" },
            { text = "打坝", comment = "da ba" },
            { text = "打扒", comment = "da ba" },
        },
        ["da ban"] = {
            { text = "打扮", comment = "da ban" },
            { text = "大班", comment = "da ban" },
            { text = "大板", comment = "da ban" },
            { text = "大半", comment = "da ban" },
            { text = "打板", comment = "da ban" },
            { text = "大阪", comment = "da ban" },
            { text = "打版", comment = "da ban" },
            { text = "搭班", comment = "da ban" },
            { text = "大版", comment = "da ban" },
            { text = "搭板", comment = "da ban" },
            { text = "大办", comment = "da ban" },
            { text = "搭伴", comment = "da ban" },
            { text = "达板", comment = "da ban" },
        },
        ["da bao"] = {
            { text = "打包", comment = "da bao" },
            { text = "大宝", comment = "da bao" },
            { text = "打爆", comment = "da bao" },
            { text = "大包", comment = "da bao" },
            { text = "打宝", comment = "da bao" },
            { text = "大爆", comment = "da bao" },
            { text = "打薄", comment = "da bao" },
            { text = "大保", comment = "da bao" },
            { text = "大堡", comment = "da bao" },
            { text = "大报", comment = "da bao" },
            { text = "达宝", comment = "da bao" },
            { text = "大鸨", comment = "da bao" },
            { text = "打苞", comment = "da bao" },
            { text = "褡包", comment = "da bao" },
        },
        ["da bei"] = {
            { text = "大杯", comment = "da bei" },
            { text = "打呗", comment = "da bei" },
            { text = "大北", comment = "da bei" },
            { text = "大悲", comment = "da bei" },
            { text = "大贝", comment = "da bei" },
            { text = "大被", comment = "da bei" },
            { text = "搭背", comment = "da bei" },
            { text = "瘩背", comment = "da bei" },
        },
        ["da bei fang"] = {
            { text = "大北方", comment = "da bei fang" },
        },
        ["da ben"] = {
            { text = "打本", comment = "da ben" },
            { text = "大本", comment = "da ben" },
            { text = "大奔", comment = "da ben" },
        },
        ["da bi yu"] = {
            { text = "打比喻", comment = "da bi yu" },
        },
        ["da bie"] = {
            { text = "大别", comment = "da bie" },
        },
        ["da bin"] = {
            { text = "大斌", comment = "da bin" },
            { text = "大彬", comment = "da bin" },
            { text = "大宾", comment = "da bin" },
        },
        ["da bo"] = {
            { text = "大伯", comment = "da bo" },
            { text = "大波", comment = "da bo" },
            { text = "打啵", comment = "da bo" },
            { text = "大博", comment = "da bo" },
            { text = "达博", comment = "da bo" },
            { text = "大泊", comment = "da bo" },
        },
        ["da bo ai"] = {
            { text = "达伯埃", comment = "da bo ai" },
        },
        ["da bu"] = {
            { text = "打不", comment = "da bu" },
            { text = "大不", comment = "da bu" },
            { text = "大补", comment = "da bu" },
            { text = "大步", comment = "da bu" },
            { text = "大部", comment = "da bu" },
            { text = "大埔", comment = "da bu" },
            { text = "大布", comment = "da bu" },
            { text = "达布", comment = "da bu" },
            { text = "大埠", comment = "da bu" },
            { text = "搭补", comment = "da bu" },
        },
        ["da fo"] = {
            { text = "大佛", comment = "da fo" },
        },
        ["da fo si"] = {
            { text = "大佛寺", comment = "da fo si" },
        },
        ["da hua ao"] = {
            { text = "大花袄", comment = "da hua ao" },
        },
        ["da huai"] = {
            { text = "打坏", comment = "da huai" },
            { text = "大槐", comment = "da huai" },
        },
        ["da ji dan"] = {
            { text = "打鸡蛋", comment = "da ji dan" },
        },
        ["da jie an"] = {
            { text = "大劫案", comment = "da jie an" },
        },
        ["da nao"] = {
            { text = "大脑", comment = "da nao" },
            { text = "大闹", comment = "da nao" },
            { text = "打闹", comment = "da nao" },
        },
        ["da nei"] = {
            { text = "达内", comment = "da nei" },
            { text = "大内", comment = "da nei" },
        },
        ["da nin"] = {
            { text = "打您", comment = "da nin" },
        },
        ["da niu"] = {
            { text = "大牛", comment = "da niu" },
            { text = "大妞", comment = "da niu" },
            { text = "打牛", comment = "da niu" },
        },
        ["da nuan"] = {
            { text = "大暖", comment = "da nuan" },
        },
        ["da nuo"] = {
            { text = "达诺", comment = "da nuo" },
            { text = "大诺", comment = "da nuo" },
        },
        ["da ou"] = {
            { text = "大欧", comment = "da ou" },
            { text = "打偶", comment = "da ou" },
        },
        ["da qi e"] = {
            { text = "打企鹅", comment = "da qi e" },
        },
        ["da qie"] = {
            { text = "大切", comment = "da qie" },
            { text = "打切", comment = "da qie" },
        },
        ["da rao"] = {
            { text = "打扰", comment = "da rao" },
        },
        ["da ri"] = {
            { text = "大日", comment = "da ri" },
            { text = "达日", comment = "da ri" },
        },
        ["da ta"] = {
            { text = "打他", comment = "da ta" },
            { text = "打她", comment = "da ta" },
            { text = "打塔", comment = "da ta" },
            { text = "打它", comment = "da ta" },
            { text = "大塔", comment = "da ta" },
        },
        ["da ta bu"] = {
            { text = "大踏步", comment = "da ta bu" },
        },
        ["da tai"] = {
            { text = "打胎", comment = "da tai" },
            { text = "搭台", comment = "da tai" },
            { text = "大台", comment = "da tai" },
            { text = "达泰", comment = "da tai" },
            { text = "大泰", comment = "da tai" },
        },
        ["da tan"] = {
            { text = "打探", comment = "da tan" },
            { text = "大谈", comment = "da tan" },
            { text = "大滩", comment = "da tan" },
            { text = "大谭", comment = "da tan" },
            { text = "大潭", comment = "da tan" },
        },
        ["da tan ke"] = {
            { text = "大坦克", comment = "da tan ke" },
        },
        ["da tie"] = {
            { text = "打铁", comment = "da tie" },
            { text = "大铁", comment = "da tie" },
            { text = "搭铁", comment = "da tie" },
            { text = "大贴", comment = "da tie" },
        },
        ["da tou"] = {
            { text = "大头", comment = "da tou" },
            { text = "打头", comment = "da tou" },
            { text = "打投", comment = "da tou" },
            { text = "搭头", comment = "da tou" },
            { text = "大投", comment = "da tou" },
        },
        ["da tu di"] = {
            { text = "大徒弟", comment = "da tu di" },
        },
        ["da tuo"] = {
            { text = "打托", comment = "da tuo" },
            { text = "大托", comment = "da tuo" },
            { text = "大坨", comment = "da tuo" },
            { text = "大拓", comment = "da tuo" },
            { text = "达托", comment = "da tuo" },
        },
        ["da ya"] = {
            { text = "打压", comment = "da ya" },
            { text = "大牙", comment = "da ya" },
            { text = "打呀", comment = "da ya" },
            { text = "大雅", comment = "da ya" },
            { text = "大亚", comment = "da ya" },
            { text = "大呀", comment = "da ya" },
            { text = "大丫", comment = "da ya" },
            { text = "达亚", comment = "da ya" },
            { text = "大垭", comment = "da ya" },
            { text = "大衙", comment = "da ya" },
        },
        ["da yan"] = {
            { text = "大眼", comment = "da yan" },
            { text = "大雁", comment = "da yan" },
            { text = "打眼", comment = "da yan" },
            { text = "大燕", comment = "da yan" },
            { text = "大烟", comment = "da yan" },
            { text = "大堰", comment = "da yan" },
            { text = "大宴", comment = "da yan" },
            { text = "大岩", comment = "da yan" },
            { text = "大研", comment = "da yan" },
            { text = "大艳", comment = "da yan" },
            { text = "大盐", comment = "da yan" },
            { text = "答言", comment = "da yan" },
        },
        ["da yang"] = {
            { text = "打样", comment = "da yang" },
            { text = "大洋", comment = "da yang" },
            { text = "大样", comment = "da yang" },
            { text = "打烊", comment = "da yang" },
            { text = "大阳", comment = "da yang" },
            { text = "大杨", comment = "da yang" },
            { text = "大羊", comment = "da yang" },
            { text = "打氧", comment = "da yang" },
            { text = "打羊", comment = "da yang" },
            { text = "达洋", comment = "da yang" },
            { text = "达阳", comment = "da yang" },
            { text = "大央", comment = "da yang" },
        },
        ["da yao"] = {
            { text = "大药", comment = "da yao" },
            { text = "打药", comment = "da yao" },
            { text = "大姚", comment = "da yao" },
            { text = "大窑", comment = "da yao" },
            { text = "大瑶", comment = "da yao" },
            { text = "大妖", comment = "da yao" },
            { text = "大尧", comment = "da yao" },
            { text = "大耀", comment = "da yao" },
            { text = "大腰", comment = "da yao" },
            { text = "大要", comment = "da yao" },
            { text = "搭腰", comment = "da yao" },
        },
        ["da ye"] = {
            { text = "大爷", comment = "da ye" },
            { text = "打野", comment = "da ye" },
            { text = "大业", comment = "da ye" },
            { text = "大冶", comment = "da ye" },
            { text = "大夜", comment = "da ye" },
            { text = "大叶", comment = "da ye" },
            { text = "大野", comment = "da ye" },
            { text = "达也", comment = "da ye" },
            { text = "大烨", comment = "da ye" },
            { text = "打叶", comment = "da ye" },
        },
        ["da ye ye"] = {
            { text = "大爷爷", comment = "da ye ye" },
        },
        ["da yi nv"] = {
            { text = "大衣女", comment = "da yi nv" },
        },
        ["da yin"] = {
            { text = "打印", comment = "da yin" },
            { text = "大隐", comment = "da yin" },
            { text = "达因", comment = "da yin" },
            { text = "大印", comment = "da yin" },
            { text = "大阴", comment = "da yin" },
            { text = "大银", comment = "da yin" },
            { text = "大音", comment = "da yin" },
            { text = "大因", comment = "da yin" },
        },
        ["da yin hao"] = {
            { text = "打印好", comment = "da yin hao" },
        },
        ["da you"] = {
            { text = "大有", comment = "da you" },
            { text = "打油", comment = "da you" },
            { text = "大友", comment = "da you" },
            { text = "大油", comment = "da you" },
            { text = "大优", comment = "da you" },
            { text = "大佑", comment = "da you" },
            { text = "达优", comment = "da you" },
            { text = "大由", comment = "da you" },
        },
        ["da yuan"] = {
            { text = "大院", comment = "da yuan" },
            { text = "大元", comment = "da yuan" },
            { text = "大源", comment = "da yuan" },
            { text = "大圆", comment = "da yuan" },
            { text = "大员", comment = "da yuan" },
            { text = "大园", comment = "da yuan" },
            { text = "达源", comment = "da yuan" },
            { text = "大远", comment = "da yuan" },
            { text = "大愿", comment = "da yuan" },
            { text = "大原", comment = "da yuan" },
            { text = "达远", comment = "da yuan" },
            { text = "大媛", comment = "da yuan" },
            { text = "大袁", comment = "da yuan" },
            { text = "达元", comment = "da yuan" },
            { text = "大垸", comment = "da yuan" },
            { text = "达园", comment = "da yuan" },
            { text = "大苑", comment = "da yuan" },
            { text = "打援", comment = "da yuan" },
            { text = "大缘", comment = "da yuan" },
            { text = "大院", comment = "da yuan" },
            { text = "大元", comment = "da yuan" },
            { text = "大源", comment = "da yuan" },
            { text = "大圆", comment = "da yuan" },
            { text = "大员", comment = "da yuan" },
            { text = "大园", comment = "da yuan" },
            { text = "达源", comment = "da yuan" },
            { text = "大远", comment = "da yuan" },
            { text = "大愿", comment = "da yuan" },
            { text = "大原", comment = "da yuan" },
            { text = "达远", comment = "da yuan" },
            { text = "大媛", comment = "da yuan" },
            { text = "大袁", comment = "da yuan" },
            { text = "达元", comment = "da yuan" },
            { text = "大垸", comment = "da yuan" },
            { text = "达园", comment = "da yuan" },
            { text = "大苑", comment = "da yuan" },
            { text = "打援", comment = "da yuan" },
            { text = "大缘", comment = "da yuan" },
        },
        ["da yue"] = {
            { text = "大约", comment = "da yue" },
            { text = "大悦", comment = "da yue" },
            { text = "大月", comment = "da yue" },
            { text = "答曰", comment = "da yue" },
            { text = "大岳", comment = "da yue" },
            { text = "大越", comment = "da yue" },
        },
        ["dai a"] = {
            { text = "带啊", comment = "dai a" },
        },
        ["dai an"] = {
            { text = "戴安", comment = "dai an" },
            { text = "带俺", comment = "dai an" },
        },
        ["dai ang"] = {
            { text = "戴昂", comment = "dai ang" },
        },
        ["dai ao"] = {
            { text = "代傲", comment = "dai ao" },
        },
        ["dai bu"] = {
            { text = "逮捕", comment = "dai bu" },
            { text = "代步", comment = "dai bu" },
            { text = "带不", comment = "dai bu" },
            { text = "待补", comment = "dai bu" },
            { text = "代补", comment = "dai bu" },
            { text = "戴埠", comment = "dai bu" },
            { text = "代布", comment = "dai bu" },
            { text = "代部", comment = "dai bu" },
        },
        ["dai die"] = {
            { text = "傣揲", comment = "dai die" },
        },
        ["dai e"] = {
            { text = "呆鹅", comment = "dai e" },
            { text = "带哦", comment = "dai e" },
        },
        ["dai ne"] = {
            { text = "带呢", comment = "dai ne" },
        },
        ["dai ou"] = {
            { text = "戴欧", comment = "dai ou" },
            { text = "戴欧", comment = "dai ou" },
        },
        ["dai xu"] = {
            { text = "待续", comment = "dai xu" },
            { text = "戴旭", comment = "dai xu" },
            { text = "代旭", comment = "dai xu" },
            { text = "代序", comment = "dai xu" },
        },
        ["dai yu"] = {
            { text = "待遇", comment = "dai yu" },
            { text = "带鱼", comment = "dai yu" },
            { text = "黛玉", comment = "dai yu" },
            { text = "怠于", comment = "dai yu" },
            { text = "代玉", comment = "dai yu" },
            { text = "戴宇", comment = "dai yu" },
            { text = "代宇", comment = "dai yu" },
            { text = "戴钰", comment = "dai yu" },
        },
        ["dai yu hao"] = {
            { text = "待遇好", comment = "dai yu hao" },
        },
        ["dai yun"] = {
            { text = "代孕", comment = "dai yun" },
            { text = "代运", comment = "dai yun" },
            { text = "戴云", comment = "dai yun" },
            { text = "待孕", comment = "dai yun" },
        },
        ["dan"] = {
            { text = "但", comment = "dan" },
            { text = "单", comment = "dan" },
            { text = "蛋", comment = "dan" },
            { text = "丹", comment = "dan" },
            { text = "淡", comment = "dan" },
            { text = "胆", comment = "dan" },
            { text = "弹", comment = "dan" },
            { text = "担", comment = "dan" },
            { text = "旦", comment = "dan" },
            { text = "氮", comment = "dan" },
            { text = "诞", comment = "dan" },
            { text = "啖", comment = "dan" },
            { text = "耽", comment = "dan" },
            { text = "掸", comment = "dan" },
            { text = "聃", comment = "dan" },
            { text = "疍", comment = "dan" },
            { text = "惮", comment = "dan" },
            { text = "郸", comment = "dan" },
            { text = "澹", comment = "dan" },
            { text = "箪", comment = "dan" },
            { text = "亻", comment = "dan" },
            { text = "卩", comment = "dan" },
            { text = "儋", comment = "dan" },
            { text = "殚", comment = "dan" },
            { text = "眈", comment = "dan" },
            { text = "石", comment = "dan" },
            { text = "亶", comment = "dan" },
            { text = "惔", comment = "dan" },
            { text = "萏", comment = "dan" },
            { text = "瘅", comment = "dan" },
            { text = "赕", comment = "dan" },
            { text = "膻", comment = "dan" },
            { text = "憺", comment = "dan" },
            { text = "嵅", comment = "dan" },
            { text = "𫢸", comment = "dan" },
            { text = "𬘘", comment = "dan" },
            { text = "𬊤", comment = "dan" },
            { text = "疸", comment = "dan" },
        },
        ["dan di"] = {
            { text = "丹迪", comment = "dan di" },
            { text = "丹堤", comment = "dan di" },
            { text = "单底", comment = "dan di" },
            { text = "丹帝", comment = "dan di" },
        },
        ["dan fo"] = {
            { text = "丹佛", comment = "dan fo" },
            { text = "赕佛", comment = "dan fo" },
        },
        ["dan wo"] = {
            { text = "但我", comment = "dan wo" },
            { text = "单卧", comment = "dan wo" },
        },
        ["dan xu"] = {
            { text = "但需", comment = "dan xu" },
            { text = "但须", comment = "dan xu" },
        },
        ["dan yu"] = {
            { text = "丹玉", comment = "dan yu" },
            { text = "但与", comment = "dan yu" },
            { text = "单语", comment = "dan yu" },
            { text = "弹雨", comment = "dan yu" },
            { text = "丹宇", comment = "dan yu" },
            { text = "丹玉", comment = "dan yu" },
            { text = "但与", comment = "dan yu" },
            { text = "单语", comment = "dan yu" },
            { text = "弹雨", comment = "dan yu" },
            { text = "丹宇", comment = "dan yu" },
        },
        ["dang a"] = {
            { text = "当啊", comment = "dang a" },
        },
        ["dang ai"] = {
            { text = "当爱", comment = "dang ai" },
        },
        ["dang an"] = {
            { text = "档案", comment = "dang an" },
        },
        ["dang an ke"] = {
            { text = "档案科", comment = "dang an ke" },
        },
        ["dang bu"] = {
            { text = "裆部", comment = "dang bu" },
            { text = "党部", comment = "dang bu" },
        },
        ["dang fou"] = {
            { text = "当否", comment = "dang fou" },
        },
        ["dang wei"] = {
            { text = "党委", comment = "dang wei" },
            { text = "档位", comment = "dang wei" },
            { text = "当为", comment = "dang wei" },
            { text = "挡位", comment = "dang wei" },
            { text = "党伟", comment = "dang wei" },
        },
        ["dang wo"] = {
            { text = "当我", comment = "dang wo" },
            { text = "挡我", comment = "dang wo" },
        },
        ["dang ye"] = {
            { text = "当夜", comment = "dang ye" },
        },
        ["dao"] = {
            { text = "到", comment = "dao" },
            { text = "倒", comment = "dao" },
            { text = "道", comment = "dao" },
            { text = "刀", comment = "dao" },
            { text = "盗", comment = "dao" },
            { text = "导", comment = "dao" },
            { text = "岛", comment = "dao" },
            { text = "稻", comment = "dao" },
            { text = "捣", comment = "dao" },
            { text = "叨", comment = "dao" },
            { text = "蹈", comment = "dao" },
            { text = "悼", comment = "dao" },
            { text = "祷", comment = "dao" },
            { text = "刂", comment = "dao" },
            { text = "氘", comment = "dao" },
            { text = "捯", comment = "dao" },
            { text = "纛", comment = "dao" },
            { text = "忉", comment = "dao" },
            { text = "焘", comment = "dao" },
            { text = "舠", comment = "dao" },
            { text = "鱽", comment = "dao" },
            { text = "帱", comment = "dao" },
        },
        ["dao a"] = {
            { text = "到啊", comment = "dao a" },
        },
        ["dao an"] = {
            { text = "到岸", comment = "dao an" },
            { text = "到案", comment = "dao an" },
            { text = "道安", comment = "dao an" },
            { text = "导案", comment = "dao an" },
            { text = "盗案", comment = "dao an" },
        },
        ["dao ao"] = {
            { text = "倒凹", comment = "dao ao" },
        },
        ["dao bai"] = {
            { text = "道白", comment = "dao bai" },
            { text = "刀摆", comment = "dao bai" },
        },
        ["dao di"] = {
            { text = "到底", comment = "dao di" },
            { text = "到地", comment = "dao di" },
            { text = "倒地", comment = "dao di" },
            { text = "到低", comment = "dao di" },
            { text = "道地", comment = "dao di" },
            { text = "到第", comment = "dao di" },
            { text = "稻地", comment = "dao di" },
            { text = "倒底", comment = "dao di" },
        },
        ["dao di fang"] = {
            { text = "到地方", comment = "dao di fang" },
        },
        ["dao en"] = {
            { text = "道恩", comment = "dao en" },
        },
        ["dao o"] = {
            { text = "到哦", comment = "dao o" },
        },
        ["dao ye"] = {
            { text = "倒也", comment = "dao ye" },
            { text = "倒爷", comment = "dao ye" },
            { text = "导叶", comment = "dao ye" },
            { text = "道爷", comment = "dao ye" },
            { text = "岛叶", comment = "dao ye" },
            { text = "到页", comment = "dao ye" },
        },
        ["dao yin"] = {
            { text = "导引", comment = "dao yin" },
            { text = "盗印", comment = "dao yin" },
            { text = "道印", comment = "dao yin" },
            { text = "导因", comment = "dao yin" },
        },
        ["dao yu"] = {
            { text = "岛屿", comment = "dao yu" },
            { text = "导语", comment = "dao yu" },
            { text = "刀鱼", comment = "dao yu" },
            { text = "叨鱼", comment = "dao yu" },
            { text = "道与", comment = "dao yu" },
            { text = "刀语", comment = "dao yu" },
        },
        ["dao yu e"] = {
            { text = "倒余额", comment = "dao yu e" },
            { text = "倒余额", comment = "dao yu e" },
        },
        ["dao yue"] = {
            { text = "到月", comment = "dao yue" },
            { text = "到月", comment = "dao yue" },
        },
        ["de"] = {
            { text = "的", comment = "de" },
            { text = "得", comment = "de" },
            { text = "德", comment = "de" },
            { text = "地", comment = "de" },
            { text = "嘚", comment = "de" },
            { text = "锝", comment = "de" },
            { text = "底", comment = "de" },
        },
        ["de a"] = {
            { text = "的啊", comment = "de a" },
            { text = "地啊", comment = "de a" },
            { text = "的阿", comment = "de a" },
        },
        ["de an"] = {
            { text = "德安", comment = "de an" },
        },
        ["de ang"] = {
            { text = "德昂", comment = "de ang" },
        },
        ["de ao"] = {
            { text = "德奥", comment = "de ao" },
            { text = "德澳", comment = "de ao" },
        },
        ["de bu"] = {
            { text = "的不", comment = "de bu" },
            { text = "的布", comment = "de bu" },
        },
        ["de de"] = {
            { text = "得的", comment = "de de" },
            { text = "得得", comment = "de de" },
            { text = "的的", comment = "de de" },
            { text = "嘚嘚", comment = "de de" },
            { text = "德德", comment = "de de" },
            { text = "德的", comment = "de de" },
            { text = "的地", comment = "de de" },
        },
        ["de di"] = {
            { text = "得地", comment = "de di" },
            { text = "的第", comment = "de di" },
            { text = "的低", comment = "de di" },
            { text = "德迪", comment = "de di" },
        },
        ["de e"] = {
            { text = "的额", comment = "de e" },
        },
        ["de ei"] = {
            { text = "的诶", comment = "de ei" },
        },
        ["de o"] = {
            { text = "的哦", comment = "de o" },
            { text = "的噢", comment = "de o" },
        },
        ["de ta"] = {
            { text = "的他", comment = "de ta" },
            { text = "的她", comment = "de ta" },
            { text = "德塔", comment = "de ta" },
        },
        ["de tai"] = {
            { text = "德泰", comment = "de tai" },
            { text = "的太", comment = "de tai" },
            { text = "得太", comment = "de tai" },
            { text = "得泰", comment = "de tai" },
            { text = "的台", comment = "de tai" },
        },
        ["de tao"] = {
            { text = "德涛", comment = "de tao" },
            { text = "地淘", comment = "de tao" },
        },
        ["de te"] = {
            { text = "德特", comment = "de te" },
        },
        ["de tie"] = {
            { text = "的贴", comment = "de tie" },
            { text = "德铁", comment = "de tie" },
            { text = "的铁", comment = "de tie" },
            { text = "的帖", comment = "de tie" },
        },
        ["de tou"] = {
            { text = "的头", comment = "de tou" },
        },
        ["de tuan"] = {
            { text = "的团", comment = "de tuan" },
        },
        ["de tuo"] = {
            { text = "的托", comment = "de tuo" },
        },
        ["de wo"] = {
            { text = "得我", comment = "de wo" },
            { text = "的我", comment = "de wo" },
            { text = "的喔", comment = "de wo" },
            { text = "德沃", comment = "de wo" },
            { text = "德卧", comment = "de wo" },
            { text = "的窝", comment = "de wo" },
        },
        ["de ye"] = {
            { text = "德业", comment = "de ye" },
            { text = "的也", comment = "de ye" },
            { text = "德爷", comment = "de ye" },
            { text = "的夜", comment = "de ye" },
            { text = "得也", comment = "de ye" },
            { text = "的叶", comment = "de ye" },
        },
        ["deng a"] = {
            { text = "等啊", comment = "deng a" },
        },
        ["deng ai"] = {
            { text = "邓艾", comment = "deng ai" },
            { text = "等爱", comment = "deng ai" },
        },
        ["deng ao"] = {
            { text = "邓傲", comment = "deng ao" },
        },
        ["deng bu"] = {
            { text = "等不", comment = "deng bu" },
            { text = "灯布", comment = "deng bu" },
            { text = "登不", comment = "deng bu" },
            { text = "邓部", comment = "deng bu" },
            { text = "登簿", comment = "deng bu" },
        },
        ["deng e"] = {
            { text = "等额", comment = "deng e" },
        },
        ["deng huai"] = {
            { text = "灯坏", comment = "deng huai" },
        },
        ["deng ou"] = {
            { text = "等偶", comment = "deng ou" },
        },
        ["deng ri"] = {
            { text = "等日", comment = "deng ri" },
        },
        ["deng wo"] = {
            { text = "等我", comment = "deng wo" },
            { text = "登我", comment = "deng wo" },
            { text = "瞪我", comment = "deng wo" },
        },
        ["deng xu"] = {
            { text = "邓旭", comment = "deng xu" },
        },
        ["deng ye"] = {
            { text = "等爷", comment = "deng ye" },
            { text = "邓烨", comment = "deng ye" },
            { text = "等也", comment = "deng ye" },
        },
        ["di"] = {
            { text = "第", comment = "di" },
            { text = "地", comment = "di" },
            { text = "低", comment = "di" },
            { text = "底", comment = "di" },
            { text = "滴", comment = "di" },
            { text = "弟", comment = "di" },
            { text = "迪", comment = "di" },
            { text = "帝", comment = "di" },
            { text = "抵", comment = "di" },
            { text = "递", comment = "di" },
            { text = "睇", comment = "di" },
            { text = "敌", comment = "di" },
            { text = "的", comment = "di" },
            { text = "蒂", comment = "di" },
            { text = "娣", comment = "di" },
            { text = "狄", comment = "di" },
            { text = "笛", comment = "di" },
            { text = "堤", comment = "di" },
            { text = "嘀", comment = "di" },
            { text = "邸", comment = "di" },
            { text = "涤", comment = "di" },
            { text = "谛", comment = "di" },
            { text = "棣", comment = "di" },
            { text = "荻", comment = "di" },
            { text = "缔", comment = "di" },
            { text = "翟", comment = "di" },
            { text = "嫡", comment = "di" },
            { text = "砥", comment = "di" },
            { text = "镝", comment = "di" },
            { text = "籴", comment = "di" },
            { text = "骶", comment = "di" },
            { text = "氐", comment = "di" },
            { text = "碲", comment = "di" },
            { text = "菂", comment = "di" },
            { text = "坻", comment = "di" },
            { text = "诋", comment = "di" },
            { text = "玓", comment = "di" },
            { text = "柢", comment = "di" },
            { text = "禘", comment = "di" },
            { text = "觌", comment = "di" },
            { text = "媂", comment = "di" },
            { text = "羝", comment = "di" },
            { text = "提", comment = "di" },
            { text = "鞮", comment = "di" },
            { text = "蹢", comment = "di" },
            { text = "踶", comment = "di" },
            { text = "遆", comment = "di" },
            { text = "髢", comment = "di" },
            { text = "浟", comment = "di" },
            { text = "泜", comment = "di" },
            { text = "疐", comment = "di" },
            { text = "䃅", comment = "di" },
            { text = "䗖", comment = "di" },
            { text = "茋", comment = "di" },
            { text = "𬱖", comment = "di" },
            { text = "𬤊", comment = "di" },
            { text = "𫶇", comment = "di" },
            { text = "𤧛", comment = "di" },
        },
        ["di a"] = {
            { text = "地啊", comment = "di a" },
            { text = "滴啊", comment = "di a" },
            { text = "低啊", comment = "di a" },
        },
        ["di an"] = {
            { text = "堤岸", comment = "di an" },
            { text = "迪安", comment = "di an" },
            { text = "涤氨", comment = "di an" },
        },
        ["di ao"] = {
            { text = "迪奥", comment = "di ao" },
            { text = "地奥", comment = "di ao" },
            { text = "帝奥", comment = "di ao" },
        },
        ["di bu"] = {
            { text = "底部", comment = "di bu" },
            { text = "地步", comment = "di bu" },
            { text = "底布", comment = "di bu" },
            { text = "递补", comment = "di bu" },
            { text = "地补", comment = "di bu" },
            { text = "抵补", comment = "di bu" },
            { text = "地布", comment = "di bu" },
            { text = "骶部", comment = "di bu" },
        },
        ["di da di"] = {
            { text = "滴答滴", comment = "di da di" },
        },
        ["di dan"] = {
            { text = "底单", comment = "di dan" },
            { text = "低氮", comment = "di dan" },
            { text = "递单", comment = "di dan" },
            { text = "地蛋", comment = "di dan" },
        },
        ["di di"] = {
            { text = "弟弟", comment = "di di" },
            { text = "滴滴", comment = "di di" },
            { text = "迪迪", comment = "di di" },
            { text = "睇睇", comment = "di di" },
            { text = "地底", comment = "di di" },
            { text = "蒂蒂", comment = "di di" },
            { text = "嘀嘀", comment = "di di" },
            { text = "低低", comment = "di di" },
            { text = "底底", comment = "di di" },
            { text = "娣娣", comment = "di di" },
            { text = "低地", comment = "di di" },
            { text = "帝帝", comment = "di di" },
            { text = "底迪", comment = "di di" },
            { text = "狄狄", comment = "di di" },
            { text = "荻荻", comment = "di di" },
            { text = "迪滴", comment = "di di" },
            { text = "棣棣", comment = "di di" },
            { text = "樀樀", comment = "di di" },
        },
        ["di di di"] = {
            { text = "滴滴滴", comment = "di di di" },
            { text = "低低地", comment = "di di di" },
        },
        ["di dou"] = {
            { text = "地豆", comment = "di dou" },
            { text = "滴斗", comment = "di dou" },
            { text = "帝都", comment = "di dou" },
        },
        ["di dui"] = {
            { text = "敌对", comment = "di dui" },
            { text = "地堆", comment = "di dui" },
        },
        ["di hao"] = {
            { text = "帝豪", comment = "di hao" },
            { text = "低耗", comment = "di hao" },
            { text = "地号", comment = "di hao" },
            { text = "迪豪", comment = "di hao" },
            { text = "帝濠", comment = "di hao" },
        },
        ["di huai"] = {
            { text = "低徊", comment = "di huai" },
        },
        ["di ma"] = {
            { text = "低吗", comment = "di ma" },
            { text = "迪马", comment = "di ma" },
            { text = "底码", comment = "di ma" },
            { text = "涤麻", comment = "di ma" },
        },
        ["di ni"] = {
            { text = "蒂尼", comment = "di ni" },
            { text = "底泥", comment = "di ni" },
        },
        ["di nuan"] = {
            { text = "地暖", comment = "di nuan" },
        },
        ["di nv"] = {
            { text = "嫡女", comment = "di nv" },
            { text = "帝女", comment = "di nv" },
        },
        ["di ou"] = {
            { text = "迪欧", comment = "di ou" },
            { text = "帝欧", comment = "di ou" },
        },
        ["di qu"] = {
            { text = "地区", comment = "di qu" },
            { text = "低区", comment = "di qu" },
            { text = "地去", comment = "di qu" },
            { text = "地屈", comment = "di qu" },
            { text = "迪曲", comment = "di qu" },
        },
        ["di ri"] = {
            { text = "第日", comment = "di ri" },
        },
        ["di ta"] = {
            { text = "蒂塔", comment = "di ta" },
        },
        ["di tai"] = {
            { text = "地台", comment = "di tai" },
            { text = "底台", comment = "di tai" },
            { text = "敌台", comment = "di tai" },
            { text = "迪泰", comment = "di tai" },
            { text = "帝泰", comment = "di tai" },
            { text = "低台", comment = "di tai" },
        },
        ["di tan"] = {
            { text = "地毯", comment = "di tan" },
            { text = "低碳", comment = "di tan" },
            { text = "地摊", comment = "di tan" },
            { text = "地坛", comment = "di tan" },
            { text = "低弹", comment = "di tan" },
            { text = "敌探", comment = "di tan" },
        },
        ["di tan hua"] = {
            { text = "低碳化", comment = "di tan hua" },
        },
        ["di tang"] = {
            { text = "低糖", comment = "di tang" },
            { text = "低塘", comment = "di tang" },
            { text = "棣棠", comment = "di tang" },
            { text = "底汤", comment = "di tang" },
            { text = "嫡堂", comment = "di tang" },
        },
        ["di tao"] = {
            { text = "地淘", comment = "di tao" },
        },
        ["di te"] = {
            { text = "迪特", comment = "di te" },
            { text = "敌特", comment = "di te" },
            { text = "地特", comment = "di te" },
            { text = "帝特", comment = "di te" },
        },
        ["di tie"] = {
            { text = "地铁", comment = "di tie" },
            { text = "地贴", comment = "di tie" },
            { text = "底贴", comment = "di tie" },
        },
        ["di tou"] = {
            { text = "低头", comment = "di tou" },
            { text = "地头", comment = "di tou" },
            { text = "笛头", comment = "di tou" },
        },
        ["di tuan"] = {
            { text = "敌团", comment = "di tuan" },
        },
        ["di tuo"] = {
            { text = "地拖", comment = "di tuo" },
            { text = "底托", comment = "di tuo" },
            { text = "帝陀", comment = "di tuo" },
            { text = "地拓", comment = "di tuo" },
        },
        ["di wa"] = {
            { text = "低洼", comment = "di wa" },
            { text = "弟娃", comment = "di wa" },
            { text = "迪瓦", comment = "di wa" },
            { text = "地挖", comment = "di wa" },
        },
        ["di wo"] = {
            { text = "敌我", comment = "di wo" },
            { text = "滴我", comment = "di wo" },
            { text = "迪沃", comment = "di wo" },
        },
        ["di ya"] = {
            { text = "抵押", comment = "di ya" },
            { text = "低压", comment = "di ya" },
            { text = "迪亚", comment = "di ya" },
            { text = "蒂亚", comment = "di ya" },
            { text = "地压", comment = "di ya" },
            { text = "迪雅", comment = "di ya" },
            { text = "帝亚", comment = "di ya" },
        },
        ["di ye"] = {
            { text = "滴液", comment = "di ye" },
            { text = "帝业", comment = "di ye" },
        },
        ["di you"] = {
            { text = "底油", comment = "di you" },
            { text = "滴油", comment = "di you" },
            { text = "低幼", comment = "di you" },
            { text = "迪优", comment = "di you" },
        },
        ["dian bu"] = {
            { text = "点不", comment = "dian bu" },
            { text = "点部", comment = "dian bu" },
            { text = "垫布", comment = "dian bu" },
            { text = "垫补", comment = "dian bu" },
            { text = "店埠", comment = "dian bu" },
            { text = "点补", comment = "dian bu" },
            { text = "垫步", comment = "dian bu" },
        },
        ["dian hua bu"] = {
            { text = "电话簿", comment = "dian hua bu" },
        },
        ["dian ji tou"] = {
            { text = "电极头", comment = "dian ji tou" },
            { text = "电机头", comment = "dian ji tou" },
        },
        ["dian jing bu"] = {
            { text = "电竞部", comment = "dian jing bu" },
        },
        ["dian ou"] = {
            { text = "电偶", comment = "dian ou" },
        },
        ["dian rou"] = {
            { text = "点肉", comment = "dian rou" },
        },
        ["die"] = {
            { text = "爹", comment = "die" },
            { text = "跌", comment = "die" },
            { text = "碟", comment = "die" },
            { text = "蝶", comment = "die" },
            { text = "叠", comment = "die" },
            { text = "谍", comment = "die" },
            { text = "迭", comment = "die" },
            { text = "喋", comment = "die" },
            { text = "牒", comment = "die" },
            { text = "咥", comment = "die" },
            { text = "堞", comment = "die" },
            { text = "鲽", comment = "die" },
            { text = "耋", comment = "die" },
            { text = "蹀", comment = "die" },
            { text = "垤", comment = "die" },
            { text = "瓞", comment = "die" },
            { text = "揲", comment = "die" },
            { text = "绖", comment = "die" },
            { text = "䏲", comment = "die" },
            { text = "渫", comment = "die" },
            { text = "鳎", comment = "die" },
        },
        ["die an"] = {
            { text = "蝶鞍", comment = "die an" },
        },
        ["die bu"] = {
            { text = "迭部", comment = "die bu" },
        },
        ["die fei"] = {
            { text = "蝶飞", comment = "die fei" },
        },
        ["ding a"] = {
            { text = "顶啊", comment = "ding a" },
        },
        ["ding ai"] = {
            { text = "丁爱", comment = "ding ai" },
        },
        ["ding an"] = {
            { text = "定案", comment = "ding an" },
            { text = "定安", comment = "ding an" },
            { text = "鼎安", comment = "ding an" },
        },
        ["ding an hua"] = {
            { text = "丁安华", comment = "ding an hua" },
        },
        ["ding ang"] = {
            { text = "丁昂", comment = "ding ang" },
        },
        ["ding ao"] = {
            { text = "丁傲", comment = "ding ao" },
            { text = "鼎奥", comment = "ding ao" },
        },
        ["ding bu"] = {
            { text = "顶部", comment = "ding bu" },
            { text = "定不", comment = "ding bu" },
            { text = "订不", comment = "ding bu" },
            { text = "定补", comment = "ding bu" },
            { text = "丁部", comment = "ding bu" },
        },
        ["ding e"] = {
            { text = "定额", comment = "ding e" },
            { text = "顶额", comment = "ding e" },
            { text = "顶哦", comment = "ding e" },
        },
        ["ding ou"] = {
            { text = "丁欧", comment = "ding ou" },
        },
        ["ding wo"] = {
            { text = "顶我", comment = "ding wo" },
            { text = "盯我", comment = "ding wo" },
            { text = "鼎沃", comment = "ding wo" },
        },
        ["ding xu"] = {
            { text = "丁旭", comment = "ding xu" },
            { text = "鼎旭", comment = "ding xu" },
        },
        ["ding ye"] = {
            { text = "鼎业", comment = "ding ye" },
            { text = "顶叶", comment = "ding ye" },
            { text = "丁烨", comment = "ding ye" },
            { text = "丁页", comment = "ding ye" },
            { text = "丁晔", comment = "ding ye" },
        },
        ["diu"] = {
            { text = "丢", comment = "diu" },
            { text = "铥", comment = "diu" },
        },
        ["diu a"] = {
            { text = "丢啊", comment = "diu a" },
        },
        ["diu dao"] = {
            { text = "丢到", comment = "diu dao" },
        },
        ["diu ge"] = {
            { text = "丢个", comment = "diu ge" },
        },
        ["diu jia"] = {
            { text = "丢家", comment = "diu jia" },
            { text = "丢架", comment = "diu jia" },
        },
        ["diu qu"] = {
            { text = "丢去", comment = "diu qu" },
        },
        ["diu rou"] = {
            { text = "丢肉", comment = "diu rou" },
        },
        ["diu wan"] = {
            { text = "丢完", comment = "diu wan" },
        },
        ["dong a"] = {
            { text = "懂啊", comment = "dong a" },
            { text = "东阿", comment = "dong a" },
        },
        ["dong ai"] = {
            { text = "懂爱", comment = "dong ai" },
        },
        ["dong an"] = {
            { text = "东安", comment = "dong an" },
            { text = "东岸", comment = "dong an" },
            { text = "冬安", comment = "dong an" },
        },
        ["dong ang"] = {
            { text = "东昂", comment = "dong ang" },
        },
        ["dong ao"] = {
            { text = "东奥", comment = "dong ao" },
            { text = "冬奥", comment = "dong ao" },
            { text = "东澳", comment = "dong ao" },
        },
        ["dong bei bu"] = {
            { text = "东北部", comment = "dong bei bu" },
        },
        ["dong bei ou"] = {
            { text = "东北欧", comment = "dong bei ou" },
        },
        ["dong bu"] = {
            { text = "东部", comment = "dong bu" },
            { text = "懂不", comment = "dong bu" },
            { text = "动不", comment = "dong bu" },
            { text = "动捕", comment = "dong bu" },
            { text = "董部", comment = "dong bu" },
            { text = "冬捕", comment = "dong bu" },
            { text = "动补", comment = "dong bu" },
            { text = "东埠", comment = "dong bu" },
        },
        ["dong bu dong"] = {
            { text = "动不动", comment = "dong bu dong" },
            { text = "懂不懂", comment = "dong bu dong" },
            { text = "冻不冻", comment = "dong bu dong" },
        },
        ["dong e"] = {
            { text = "东阿", comment = "dong e" },
        },
        ["dong hua bu"] = {
            { text = "动画部", comment = "dong hua bu" },
        },
        ["dong huai"] = {
            { text = "冻坏", comment = "dong huai" },
        },
        ["dong ou"] = {
            { text = "东欧", comment = "dong ou" },
            { text = "东瓯", comment = "dong ou" },
        },
        ["dong ou dong"] = {
            { text = "东欧东", comment = "dong ou dong" },
        },
        ["dong ri"] = {
            { text = "冬日", comment = "dong ri" },
            { text = "东日", comment = "dong ri" },
        },
        ["dong rou"] = {
            { text = "冻肉", comment = "dong rou" },
        },
        ["dong wei"] = {
            { text = "董伟", comment = "dong wei" },
            { text = "东伟", comment = "dong wei" },
            { text = "东威", comment = "dong wei" },
            { text = "董威", comment = "dong wei" },
            { text = "东魏", comment = "dong wei" },
            { text = "东卫", comment = "dong wei" },
            { text = "董薇", comment = "dong wei" },
            { text = "东微", comment = "dong wei" },
            { text = "董玮", comment = "dong wei" },
            { text = "董巍", comment = "dong wei" },
            { text = "东维", comment = "dong wei" },
            { text = "董维", comment = "dong wei" },
            { text = "董卫", comment = "dong wei" },
            { text = "董炜", comment = "dong wei" },
            { text = "冬伟", comment = "dong wei" },
            { text = "东炜", comment = "dong wei" },
        },
        ["dong wo"] = {
            { text = "懂我", comment = "dong wo" },
            { text = "动我", comment = "dong wo" },
            { text = "动卧", comment = "dong wo" },
            { text = "东卧", comment = "dong wo" },
            { text = "东沃", comment = "dong wo" },
            { text = "动窝", comment = "dong wo" },
            { text = "冬握", comment = "dong wo" },
        },
        ["dong xu"] = {
            { text = "东旭", comment = "dong xu" },
            { text = "董旭", comment = "dong xu" },
            { text = "洞虚", comment = "dong xu" },
            { text = "东圩", comment = "dong xu" },
            { text = "东序", comment = "dong xu" },
            { text = "冬旭", comment = "dong xu" },
        },
        ["dong ye"] = {
            { text = "冬夜", comment = "dong ye" },
            { text = "东野", comment = "dong ye" },
            { text = "东业", comment = "dong ye" },
            { text = "东冶", comment = "dong ye" },
            { text = "东爷", comment = "dong ye" },
            { text = "董烨", comment = "dong ye" },
        },
        ["dou"] = {
            { text = "都", comment = "dou" },
            { text = "斗", comment = "dou" },
            { text = "逗", comment = "dou" },
            { text = "豆", comment = "dou" },
            { text = "抖", comment = "dou" },
            { text = "兜", comment = "dou" },
            { text = "痘", comment = "dou" },
            { text = "窦", comment = "dou" },
            { text = "陡", comment = "dou" },
            { text = "蔸", comment = "dou" },
            { text = "篼", comment = "dou" },
            { text = "蚪", comment = "dou" },
            { text = "钭", comment = "dou" },
            { text = "读", comment = "dou" },
        },
        ["dou ai"] = {
            { text = "都爱", comment = "dou ai" },
            { text = "逗爱", comment = "dou ai" },
        },
        ["dou an"] = {
            { text = "都按", comment = "dou an" },
        },
        ["dou bu"] = {
            { text = "都不", comment = "dou bu" },
            { text = "都补", comment = "dou bu" },
            { text = "兜布", comment = "dou bu" },
            { text = "窦部", comment = "dou bu" },
            { text = "斗布", comment = "dou bu" },
            { text = "兜捕", comment = "dou bu" },
        },
        ["dou di"] = {
            { text = "兜底", comment = "dou di" },
            { text = "都低", comment = "dou di" },
            { text = "斗帝", comment = "dou di" },
            { text = "斗底", comment = "dou di" },
        },
        ["dou e"] = {
            { text = "窦娥", comment = "dou e" },
        },
        ["dou en"] = {
            { text = "都恩", comment = "dou en" },
        },
        ["dou ou"] = {
            { text = "斗殴", comment = "dou ou" },
        },
        ["dou shi"] = {
            { text = "都是", comment = "dou shi" },
            { text = "斗士", comment = "dou shi" },
            { text = "都试", comment = "dou shi" },
            { text = "都事", comment = "dou shi" },
            { text = "逗是", comment = "dou shi" },
            { text = "都时", comment = "dou shi" },
            { text = "豆是", comment = "dou shi" },
            { text = "豆石", comment = "dou shi" },
            { text = "斗室", comment = "dou shi" },
            { text = "都使", comment = "dou shi" },
        },
        ["dou si"] = {
            { text = "都死", comment = "dou si" },
            { text = "逗死", comment = "dou si" },
            { text = "豆丝", comment = "dou si" },
        },
        ["dou zhe"] = {
            { text = "都这", comment = "dou zhe" },
            { text = "兜着", comment = "dou zhe" },
            { text = "逗着", comment = "dou zhe" },
            { text = "斗者", comment = "dou zhe" },
        },
        ["du ai"] = {
            { text = "独爱", comment = "du ai" },
            { text = "笃爱", comment = "du ai" },
        },
        ["du an"] = {
            { text = "都安", comment = "du an" },
            { text = "毒案", comment = "du an" },
        },
        ["du ang"] = {
            { text = "杜昂", comment = "du ang" },
        },
        ["du ba"] = {
            { text = "毒霸", comment = "du ba" },
            { text = "独霸", comment = "du ba" },
            { text = "赌霸", comment = "du ba" },
        },
        ["du bai"] = {
            { text = "独白", comment = "du bai" },
            { text = "镀白", comment = "du bai" },
            { text = "杜拜", comment = "du bai" },
        },
        ["du ban"] = {
            { text = "督办", comment = "du ban" },
            { text = "堵板", comment = "du ban" },
        },
        ["du bang"] = {
            { text = "杜邦", comment = "du bang" },
            { text = "都邦", comment = "du bang" },
            { text = "度邦", comment = "du bang" },
        },
        ["du bei"] = {
            { text = "读背", comment = "du bei" },
            { text = "杜北", comment = "du bei" },
        },
        ["du ben"] = {
            { text = "读本", comment = "du ben" },
            { text = "赌本", comment = "du ben" },
        },
        ["du bin"] = {
            { text = "杜斌", comment = "du bin" },
            { text = "杜宾", comment = "du bin" },
            { text = "杜彬", comment = "du bin" },
        },
        ["du bo"] = {
            { text = "赌博", comment = "du bo" },
            { text = "读博", comment = "du bo" },
            { text = "独播", comment = "du bo" },
            { text = "杜波", comment = "du bo" },
            { text = "杜博", comment = "du bo" },
        },
        ["du di"] = {
            { text = "毒地", comment = "du di" },
            { text = "杜迪", comment = "du di" },
        },
        ["du en"] = {
            { text = "都恩", comment = "du en" },
        },
        ["du nan"] = {
            { text = "肚腩", comment = "du nan" },
            { text = "杜楠", comment = "du nan" },
            { text = "毒男", comment = "du nan" },
            { text = "杜南", comment = "du nan" },
            { text = "度难", comment = "du nan" },
        },
        ["du nei"] = {
            { text = "都内", comment = "du nei" },
        },
        ["du niu"] = {
            { text = "犊牛", comment = "du niu" },
        },
        ["du ya"] = {
            { text = "毒牙", comment = "du ya" },
            { text = "渡鸦", comment = "du ya" },
            { text = "杜亚", comment = "du ya" },
            { text = "堵牙", comment = "du ya" },
        },
        ["du yan"] = {
            { text = "读研", comment = "du yan" },
            { text = "独眼", comment = "du yan" },
            { text = "杜艳", comment = "du yan" },
            { text = "杜燕", comment = "du yan" },
            { text = "杜岩", comment = "du yan" },
            { text = "度言", comment = "du yan" },
            { text = "杜妍", comment = "du yan" },
        },
        ["du yang"] = {
            { text = "杜洋", comment = "du yang" },
            { text = "杜阳", comment = "du yang" },
            { text = "杜杨", comment = "du yang" },
            { text = "都杨", comment = "du yang" },
            { text = "都阳", comment = "du yang" },
        },
        ["du yao"] = {
            { text = "毒药", comment = "du yao" },
            { text = "杜瑶", comment = "du yao" },
            { text = "杜尧", comment = "du yao" },
        },
        ["du ye"] = {
            { text = "毒液", comment = "du ye" },
            { text = "镀液", comment = "du ye" },
            { text = "杜烨", comment = "du ye" },
        },
        ["du yin"] = {
            { text = "读音", comment = "du yin" },
            { text = "镀银", comment = "du yin" },
            { text = "毒瘾", comment = "du yin" },
            { text = "独饮", comment = "du yin" },
            { text = "赌瘾", comment = "du yin" },
        },
        ["du you"] = {
            { text = "独有", comment = "du you" },
        },
        ["du yuan"] = {
            { text = "独院", comment = "du yuan" },
            { text = "杜远", comment = "du yuan" },
            { text = "杜源", comment = "du yuan" },
            { text = "杜元", comment = "du yuan" },
            { text = "杜媛", comment = "du yuan" },
            { text = "杜园", comment = "du yuan" },
        },
        ["du yue"] = {
            { text = "赌约", comment = "du yue" },
            { text = "杜悦", comment = "du yue" },
            { text = "杜月", comment = "du yue" },
            { text = "杜越", comment = "du yue" },
            { text = "杜玥", comment = "du yue" },
            { text = "渡月", comment = "du yue" },
        },
        ["duan bu"] = {
            { text = "端部", comment = "duan bu" },
            { text = "段部", comment = "duan bu" },
        },
        ["duan e"] = {
            { text = "断恶", comment = "duan e" },
        },
        ["duan ou"] = {
            { text = "段鸥", comment = "duan ou" },
        },
        ["dui a"] = {
            { text = "对啊", comment = "dui a" },
            { text = "对阿", comment = "dui a" },
            { text = "对吖", comment = "dui a" },
        },
        ["dui an"] = {
            { text = "对岸", comment = "dui an" },
        },
        ["dui ang"] = {
            { text = "对昂", comment = "dui ang" },
        },
        ["dui ao"] = {
            { text = "对奥", comment = "dui ao" },
        },
        ["dui bu"] = {
            { text = "对不", comment = "dui bu" },
            { text = "队部", comment = "dui bu" },
            { text = "对簿", comment = "dui bu" },
        },
        ["dui di"] = {
            { text = "对滴", comment = "dui di" },
            { text = "对地", comment = "dui di" },
            { text = "对敌", comment = "dui di" },
            { text = "对抵", comment = "dui di" },
        },
        ["dui e"] = {
            { text = "对哦", comment = "dui e" },
            { text = "对俄", comment = "dui e" },
            { text = "对额", comment = "dui e" },
        },
        ["dui ei"] = {
            { text = "对诶", comment = "dui ei" },
        },
        ["dui ne"] = {
            { text = "对呢", comment = "dui ne" },
        },
        ["dui ou"] = {
            { text = "对偶", comment = "dui ou" },
            { text = "对偶", comment = "dui ou" },
        },
        ["dui yu"] = {
            { text = "对于", comment = "dui yu" },
            { text = "对与", comment = "dui yu" },
            { text = "对於", comment = "dui yu" },
        },
        ["dun an"] = {
            { text = "盾安", comment = "dun an" },
        },
        ["dun di"] = {
            { text = "遁地", comment = "dun di" },
            { text = "墩地", comment = "dun di" },
        },
        ["dun yu"] = {
            { text = "炖鱼", comment = "dun yu" },
        },
        ["duo"] = {
            { text = "多", comment = "duo" },
            { text = "躲", comment = "duo" },
            { text = "朵", comment = "duo" },
            { text = "夺", comment = "duo" },
            { text = "剁", comment = "duo" },
            { text = "哆", comment = "duo" },
            { text = "舵", comment = "duo" },
            { text = "跺", comment = "duo" },
            { text = "堕", comment = "duo" },
            { text = "铎", comment = "duo" },
            { text = "垛", comment = "duo" },
            { text = "踱", comment = "duo" },
            { text = "惰", comment = "duo" },
            { text = "哚", comment = "duo" },
            { text = "掇", comment = "duo" },
            { text = "度", comment = "duo" },
            { text = "咄", comment = "duo" },
            { text = "驮", comment = "duo" },
            { text = "埵", comment = "duo" },
            { text = "柁", comment = "duo" },
            { text = "隳", comment = "duo" },
            { text = "裰", comment = "duo" },
            { text = "亸", comment = "duo" },
            { text = "剟", comment = "duo" },
            { text = "沲", comment = "duo" },
            { text = "缍", comment = "duo" },
            { text = "杕", comment = "duo" },
            { text = "饳", comment = "duo" },
            { text = "㙍", comment = "duo" },
        },
        ["duo a"] = {
            { text = "多啊", comment = "duo a" },
        },
        ["duo ai"] = {
            { text = "多爱", comment = "duo ai" },
            { text = "夺爱", comment = "duo ai" },
        },
        ["duo an"] = {
            { text = "多安", comment = "duo an" },
        },
        ["duo ang"] = {
            { text = "多昂", comment = "duo ang" },
        },
        ["duo di"] = {
            { text = "多滴", comment = "duo di" },
            { text = "多低", comment = "duo di" },
            { text = "多迪", comment = "duo di" },
            { text = "多蒂", comment = "duo di" },
            { text = "夺嫡", comment = "duo di" },
            { text = "多地", comment = "duo di" },
        },
        ["duo en"] = {
            { text = "多恩", comment = "duo en" },
            { text = "朵恩", comment = "duo en" },
        },
        ["duo huai"] = {
            { text = "多坏", comment = "duo huai" },
        },
        ["duo men"] = {
            { text = "多门", comment = "duo men" },
        },
        ["duo o"] = {
            { text = "多哦", comment = "duo o" },
        },
        ["duo ri"] = {
            { text = "多日", comment = "duo ri" },
        },
        ["duo yu"] = {
            { text = "多余", comment = "duo yu" },
            { text = "多于", comment = "duo yu" },
            { text = "多与", comment = "duo yu" },
            { text = "躲雨", comment = "duo yu" },
            { text = "多雨", comment = "duo yu" },
            { text = "多鱼", comment = "duo yu" },
            { text = "多语", comment = "duo yu" },
        },
        ["e a"] = {
            { text = "饿啊", comment = "e a" },
        },
        ["e an"] = {
            { text = "哦按", comment = "e an" },
        },
        ["e ao"] = {
            { text = "俄奥", comment = "e ao" },
        },
        ["e ba"] = {
            { text = "恶霸", comment = "e ba" },
            { text = "鳄霸", comment = "e ba" },
        },
        ["e bei"] = {
            { text = "鄂北", comment = "e bei" },
        },
        ["e bu"] = {
            { text = "恶补", comment = "e bu" },
            { text = "饿不", comment = "e bu" },
            { text = "恶不", comment = "e bu" },
            { text = "鹅埠", comment = "e bu" },
            { text = "哦不", comment = "e bu" },
        },
        ["e bu e"] = {
            { text = "饿不饿", comment = "e bu e" },
        },
        ["e bu shi"] = {
            { text = "额不是", comment = "e bu shi" },
        },
        ["e bu si"] = {
            { text = "饿不死", comment = "e bu si" },
        },
        ["e bu zhe"] = {
            { text = "饿不着", comment = "e bu zhe" },
        },
        ["e da"] = {
            { text = "鄂大", comment = "e da" },
        },
        ["e dan"] = {
            { text = "鹅蛋", comment = "e dan" },
        },
        ["e dang"] = {
            { text = "恶党", comment = "e dang" },
        },
        ["e dao"] = {
            { text = "饿到", comment = "e dao" },
            { text = "鹅岛", comment = "e dao" },
        },
        ["e de"] = {
            { text = "额的", comment = "e de" },
            { text = "饿的", comment = "e de" },
            { text = "饿得", comment = "e de" },
        },
        ["e die"] = {
            { text = "鹅爹", comment = "e die" },
        },
        ["e dou"] = {
            { text = "恶斗", comment = "e dou" },
            { text = "额窦", comment = "e dou" },
        },
        ["e duo"] = {
            { text = "讹夺", comment = "e duo" },
        },
        ["e e"] = {
            { text = "呃呃", comment = "e e" },
            { text = "额额", comment = "e e" },
            { text = "饿饿", comment = "e e" },
            { text = "谔谔", comment = "e e" },
            { text = "鹅鹅", comment = "e e" },
            { text = "娥娥", comment = "e e" },
            { text = "噩噩", comment = "e e" },
        },
        ["e e e"] = {
            { text = "呃呃呃", comment = "e e e" },
            { text = "鹅鹅鹅", comment = "e e e" },
            { text = "额额额", comment = "e e e" },
        },
        ["e e e e"] = {
            { text = "鹅鹅鹅饿", comment = "e e e e" },
        },
        ["e er"] = {
            { text = "厄尔", comment = "e er" },
            { text = "俄而", comment = "e er" },
            { text = "俄尔", comment = "e er" },
        },
        ["e fa"] = {
            { text = "额发", comment = "e fa" },
        },
        ["e fan"] = {
            { text = "饿饭", comment = "e fan" },
            { text = "恶犯", comment = "e fan" },
        },
        ["e huai"] = {
            { text = "饿坏", comment = "e huai" },
        },
        ["e nan"] = {
            { text = "恶男", comment = "e nan" },
            { text = "鄂南", comment = "e nan" },
            { text = "厄难", comment = "e nan" },
        },
        ["e ne"] = {
            { text = "饿呢", comment = "e ne" },
        },
        ["e nuo"] = {
            { text = "婀娜", comment = "e nuo" },
        },
        ["e o"] = {
            { text = "饿哦", comment = "e o" },
            { text = "额哦", comment = "e o" },
        },
        ["e ri"] = {
            { text = "俄日", comment = "e ri" },
        },
        ["e wai"] = {
            { text = "额外", comment = "e wai" },
        },
        ["e wan"] = {
            { text = "扼腕", comment = "e wan" },
        },
        ["e wang"] = {
            { text = "鹅王", comment = "e wang" },
        },
        ["e wei"] = {
            { text = "额为", comment = "e wei" },
        },
        ["e wen"] = {
            { text = "俄文", comment = "e wen" },
            { text = "额纹", comment = "e wen" },
        },
        ["e wo"] = {
            { text = "额我", comment = "e wo" },
            { text = "呃我", comment = "e wo" },
            { text = "哦我", comment = "e wo" },
        },
        ["e wo men"] = {
            { text = "哦我们", comment = "e wo men" },
        },
        ["e xue"] = {
            { text = "鹅血", comment = "e xue" },
        },
        ["e ya"] = {
            { text = "饿呀", comment = "e ya" },
        },
        ["e yan"] = {
            { text = "恶言", comment = "e yan" },
            { text = "俄延", comment = "e yan" },
        },
        ["e yao"] = {
            { text = "扼要", comment = "e yao" },
        },
        ["e ye"] = {
            { text = "恶业", comment = "e ye" },
            { text = "额叶", comment = "e ye" },
            { text = "哦耶", comment = "e ye" },
        },
        ["e yi e"] = {
            { text = "饿一饿", comment = "e yi e" },
        },
        ["e you"] = {
            { text = "恶友", comment = "e you" },
        },
        ["e yu"] = {
            { text = "鳄鱼", comment = "e yu" },
            { text = "俄语", comment = "e yu" },
            { text = "阿谀", comment = "e yu" },
            { text = "恶语", comment = "e yu" },
            { text = "阿臾", comment = "e yu" },
            { text = "恶玉", comment = "e yu" },
        },
        ["e yu dao"] = {
            { text = "鳄鱼岛", comment = "e yu dao" },
        },
        ["e yu ge"] = {
            { text = "鳄鱼哥", comment = "e yu ge" },
        },
        ["e yu jia"] = {
            { text = "鳄鱼夹", comment = "e yu jia" },
        },
        ["e yu qu"] = {
            { text = "俄语区", comment = "e yu qu" },
        },
        ["e yu rou"] = {
            { text = "鳄鱼肉", comment = "e yu rou" },
        },
        ["e yu wan"] = {
            { text = "鄂豫皖", comment = "e yu wan" },
        },
        ["e yu xu"] = {
            { text = "鳄鱼恤", comment = "e yu xu" },
        },
        ["e yun"] = {
            { text = "厄运", comment = "e yun" },
            { text = "饿晕", comment = "e yun" },
            { text = "噩运", comment = "e yun" },
        },
        ["ei"] = {
            { text = "诶", comment = "ei" },
        },
        ["ei a"] = {
            { text = "诶啊", comment = "ei a" },
        },
        ["ei dui"] = {
            { text = "诶对", comment = "ei dui" },
        },
        ["ei ei"] = {
            { text = "诶诶", comment = "ei ei" },
        },
        ["ei ei ei"] = {
            { text = "诶诶诶", comment = "ei ei ei" },
        },
        ["ei hao"] = {
            { text = "诶好", comment = "ei hao" },
        },
        ["ei ma"] = {
            { text = "诶嘛", comment = "ei ma" },
        },
        ["ei ni"] = {
            { text = "诶你", comment = "ei ni" },
        },
        ["ei qu"] = {
            { text = "诶去", comment = "ei qu" },
        },
        ["ei wo"] = {
            { text = "诶我", comment = "ei wo" },
        },
        ["ei ya"] = {
            { text = "诶呀", comment = "ei ya" },
        },
        ["ei you"] = {
            { text = "诶呦", comment = "ei you" },
            { text = "诶有", comment = "ei you" },
        },
        ["en an"] = {
            { text = "恩安", comment = "en an" },
        },
        ["en bo"] = {
            { text = "恩波", comment = "en bo" },
            { text = "恩博", comment = "en bo" },
        },
        ["en e"] = {
            { text = "嗯额", comment = "en e" },
            { text = "嗯哦", comment = "en e" },
            { text = "恩哦", comment = "en e" },
        },
        ["en o o"] = {
            { text = "嗯哦哦", comment = "en o o" },
        },
        ["en wo"] = {
            { text = "恩我", comment = "en wo" },
        },
        ["er"] = {
            { text = "二", comment = "er" },
            { text = "而", comment = "er" },
            { text = "儿", comment = "er" },
            { text = "尔", comment = "er" },
            { text = "耳", comment = "er" },
            { text = "贰", comment = "er" },
            { text = "迩", comment = "er" },
            { text = "饵", comment = "er" },
            { text = "洱", comment = "er" },
            { text = "珥", comment = "er" },
            { text = "铒", comment = "er" },
            { text = "佴", comment = "er" },
            { text = "咡", comment = "er" },
            { text = "陑", comment = "er" },
            { text = "鲕", comment = "er" },
            { text = "鸸", comment = "er" },
            { text = "耏", comment = "er" },
            { text = "阝", comment = "er" },
        },
        ["er a"] = {
            { text = "儿啊", comment = "er a" },
        },
        ["er di"] = {
            { text = "二弟", comment = "er di" },
            { text = "二抵", comment = "er di" },
            { text = "耳帝", comment = "er di" },
        },
        ["er ta"] = {
            { text = "二塔", comment = "er ta" },
            { text = "而他", comment = "er ta" },
            { text = "而她", comment = "er ta" },
            { text = "而它", comment = "er ta" },
        },
        ["er tai"] = {
            { text = "二胎", comment = "er tai" },
            { text = "二台", comment = "er tai" },
            { text = "尔泰", comment = "er tai" },
            { text = "二肽", comment = "er tai" },
        },
        ["er tan"] = {
            { text = "二滩", comment = "er tan" },
        },
        ["er tang"] = {
            { text = "二塘", comment = "er tang" },
            { text = "二糖", comment = "er tang" },
            { text = "二堂", comment = "er tang" },
        },
        ["er tao"] = {
            { text = "二套", comment = "er tao" },
            { text = "耳套", comment = "er tao" },
            { text = "二涛", comment = "er tao" },
            { text = "而逃", comment = "er tao" },
        },
        ["er te"] = {
            { text = "尔特", comment = "er te" },
        },
        ["er tie"] = {
            { text = "二铁", comment = "er tie" },
            { text = "耳贴", comment = "er tie" },
        },
        ["er tou"] = {
            { text = "二头", comment = "er tou" },
        },
        ["er tu di"] = {
            { text = "二徒弟", comment = "er tu di" },
        },
        ["er tuan"] = {
            { text = "二团", comment = "er tuan" },
        },
        ["er tuo"] = {
            { text = "二拖", comment = "er tuo" },
        },
        ["er wai"] = {
            { text = "二外", comment = "er wai" },
            { text = "而外", comment = "er wai" },
        },
        ["er wan"] = {
            { text = "贰万", comment = "er wan" },
            { text = "二万", comment = "er wan" },
            { text = "尔湾", comment = "er wan" },
        },
        ["er wei"] = {
            { text = "二位", comment = "er wei" },
            { text = "二维", comment = "er wei" },
            { text = "而为", comment = "er wei" },
            { text = "二伟", comment = "er wei" },
            { text = "二尾", comment = "er wei" },
            { text = "二卫", comment = "er wei" },
            { text = "而未", comment = "er wei" },
            { text = "二威", comment = "er wei" },
        },
        ["er wen"] = {
            { text = "耳闻", comment = "er wen" },
        },
        ["fa"] = {
            { text = "发", comment = "fa" },
            { text = "法", comment = "fa" },
            { text = "罚", comment = "fa" },
            { text = "伐", comment = "fa" },
            { text = "阀", comment = "fa" },
            { text = "乏", comment = "fa" },
            { text = "筏", comment = "fa" },
            { text = "珐", comment = "fa" },
            { text = "垡", comment = "fa" },
            { text = "砝", comment = "fa" },
        },
        ["fa a"] = {
            { text = "发啊", comment = "fa a" },
        },
        ["fa an"] = {
            { text = "法案", comment = "fa an" },
            { text = "发暗", comment = "fa an" },
            { text = "发案", comment = "fa an" },
        },
        ["fa di"] = {
            { text = "法蒂", comment = "fa di" },
        },
        ["fa en"] = {
            { text = "法恩", comment = "fa en" },
        },
        ["fa fa"] = {
            { text = "发发", comment = "fa fa" },
            { text = "法法", comment = "fa fa" },
        },
        ["fa na"] = {
            { text = "发哪", comment = "fa na" },
            { text = "法娜", comment = "fa na" },
        },
        ["fa nan"] = {
            { text = "发难", comment = "fa nan" },
        },
        ["fa ne"] = {
            { text = "发呢", comment = "fa ne" },
        },
        ["fa nei"] = {
            { text = "阀内", comment = "fa nei" },
        },
        ["fa nie"] = {
            { text = "发苶", comment = "fa nie" },
        },
        ["fa nin"] = {
            { text = "发您", comment = "fa nin" },
        },
        ["fa nin le"] = {
            { text = "发您了", comment = "fa nin le" },
        },
        ["fa niu"] = {
            { text = "法牛", comment = "fa niu" },
        },
        ["fa nuo"] = {
            { text = "法诺", comment = "fa nuo" },
        },
        ["fa o"] = {
            { text = "发哦", comment = "fa o" },
        },
        ["fa ta"] = {
            { text = "发他", comment = "fa ta" },
            { text = "发她", comment = "fa ta" },
            { text = "罚他", comment = "fa ta" },
        },
        ["fa tai"] = {
            { text = "阀台", comment = "fa tai" },
        },
        ["fa tan"] = {
            { text = "法坦", comment = "fa tan" },
            { text = "发弹", comment = "fa tan" },
        },
        ["fa tao"] = {
            { text = "发套", comment = "fa tao" },
            { text = "法套", comment = "fa tao" },
            { text = "阀套", comment = "fa tao" },
        },
        ["fa tie"] = {
            { text = "发帖", comment = "fa tie" },
            { text = "法帖", comment = "fa tie" },
            { text = "发贴", comment = "fa tie" },
        },
        ["fa tou"] = {
            { text = "垡头", comment = "fa tou" },
            { text = "发投", comment = "fa tou" },
            { text = "阀头", comment = "fa tou" },
            { text = "法透", comment = "fa tou" },
            { text = "发头", comment = "fa tou" },
        },
        ["fa tuan"] = {
            { text = "发团", comment = "fa tuan" },
            { text = "法团", comment = "fa tuan" },
        },
        ["fan"] = {
            { text = "饭", comment = "fan" },
            { text = "烦", comment = "fan" },
            { text = "反", comment = "fan" },
            { text = "翻", comment = "fan" },
            { text = "犯", comment = "fan" },
            { text = "范", comment = "fan" },
            { text = "凡", comment = "fan" },
            { text = "返", comment = "fan" },
            { text = "帆", comment = "fan" },
            { text = "樊", comment = "fan" },
            { text = "番", comment = "fan" },
            { text = "泛", comment = "fan" },
            { text = "繁", comment = "fan" },
            { text = "梵", comment = "fan" },
            { text = "贩", comment = "fan" },
            { text = "幡", comment = "fan" },
            { text = "藩", comment = "fan" },
            { text = "矾", comment = "fan" },
            { text = "钒", comment = "fan" },
            { text = "畈", comment = "fan" },
            { text = "蕃", comment = "fan" },
            { text = "璠", comment = "fan" },
            { text = "蘩", comment = "fan" },
            { text = "燔", comment = "fan" },
            { text = "犭", comment = "fan" },
            { text = "攵", comment = "fan" },
            { text = "氾", comment = "fan" },
            { text = "蹯", comment = "fan" },
            { text = "墦", comment = "fan" },
            { text = "沨", comment = "fan" },
            { text = "𫔍", comment = "fan" },
            { text = "𬸪", comment = "fan" },
        },
        ["fan a"] = {
            { text = "烦啊", comment = "fan a" },
        },
        ["fan an"] = {
            { text = "翻案", comment = "fan an" },
            { text = "犯案", comment = "fan an" },
        },
        ["fan bu"] = {
            { text = "帆布", comment = "fan bu" },
            { text = "饭补", comment = "fan bu" },
            { text = "反哺", comment = "fan bu" },
            { text = "反补", comment = "fan bu" },
            { text = "翻布", comment = "fan bu" },
        },
        ["fan di"] = {
            { text = "翻地", comment = "fan di" },
            { text = "反帝", comment = "fan di" },
            { text = "樊迪", comment = "fan di" },
            { text = "范迪", comment = "fan di" },
            { text = "凡迪", comment = "fan di" },
            { text = "梵迪", comment = "fan di" },
        },
        ["fan e"] = {
            { text = "烦哦", comment = "fan e" },
        },
        ["fan huai"] = {
            { text = "犯坏", comment = "fan huai" },
        },
        ["fan ou"] = {
            { text = "泛欧", comment = "fan ou" },
            { text = "范鸥", comment = "fan ou" },
        },
        ["fan ri"] = {
            { text = "反日", comment = "fan ri" },
        },
        ["fan wo"] = {
            { text = "烦我", comment = "fan wo" },
            { text = "翻我", comment = "fan wo" },
            { text = "反我", comment = "fan wo" },
            { text = "返我", comment = "fan wo" },
        },
        ["fan ye"] = {
            { text = "翻页", comment = "fan ye" },
            { text = "反野", comment = "fan ye" },
            { text = "范爷", comment = "fan ye" },
            { text = "范晔", comment = "fan ye" },
            { text = "饭爷", comment = "fan ye" },
            { text = "帆爷", comment = "fan ye" },
        },
        ["fan yu"] = {
            { text = "繁育", comment = "fan yu" },
            { text = "反语", comment = "fan yu" },
            { text = "范宇", comment = "fan yu" },
            { text = "梵语", comment = "fan yu" },
            { text = "樊宇", comment = "fan yu" },
            { text = "翻羽", comment = "fan yu" },
            { text = "凡宇", comment = "fan yu" },
            { text = "范玉", comment = "fan yu" },
            { text = "范雨", comment = "fan yu" },
            { text = "范瑜", comment = "fan yu" },
            { text = "繁育", comment = "fan yu" },
            { text = "反语", comment = "fan yu" },
            { text = "范宇", comment = "fan yu" },
            { text = "梵语", comment = "fan yu" },
            { text = "樊宇", comment = "fan yu" },
            { text = "翻羽", comment = "fan yu" },
            { text = "凡宇", comment = "fan yu" },
            { text = "范玉", comment = "fan yu" },
            { text = "范雨", comment = "fan yu" },
            { text = "范瑜", comment = "fan yu" },
        },
        ["fan yu le"] = {
            { text = "泛娱乐", comment = "fan yu le" },
        },
        ["fang a"] = {
            { text = "放啊", comment = "fang a" },
        },
        ["fang ai"] = {
            { text = "妨碍", comment = "fang ai" },
            { text = "防癌", comment = "fang ai" },
            { text = "防艾", comment = "fang ai" },
        },
        ["fang an"] = {
            { text = "方案", comment = "fang an" },
        },
        ["fang bu"] = {
            { text = "房补", comment = "fang bu" },
            { text = "放不", comment = "fang bu" },
            { text = "方步", comment = "fang bu" },
            { text = "方埠", comment = "fang bu" },
            { text = "放步", comment = "fang bu" },
        },
        ["fang fo"] = {
            { text = "彷佛", comment = "fang fo" },
        },
        ["fang huai"] = {
            { text = "放怀", comment = "fang huai" },
            { text = "放坏", comment = "fang huai" },
        },
        ["fang ri"] = {
            { text = "访日", comment = "fang ri" },
        },
        ["fang xu"] = {
            { text = "方旭", comment = "fang xu" },
            { text = "方绪", comment = "fang xu" },
            { text = "房旭", comment = "fang xu" },
        },
        ["fang ye"] = {
            { text = "房爷", comment = "fang ye" },
            { text = "放野", comment = "fang ye" },
            { text = "放液", comment = "fang ye" },
            { text = "方野", comment = "fang ye" },
            { text = "彷烨", comment = "fang ye" },
        },
        ["fei"] = {
            { text = "飞", comment = "fei" },
            { text = "非", comment = "fei" },
            { text = "费", comment = "fei" },
            { text = "肥", comment = "fei" },
            { text = "废", comment = "fei" },
            { text = "菲", comment = "fei" },
            { text = "肺", comment = "fei" },
            { text = "妃", comment = "fei" },
            { text = "匪", comment = "fei" },
            { text = "斐", comment = "fei" },
            { text = "吠", comment = "fei" },
            { text = "霏", comment = "fei" },
            { text = "沸", comment = "fei" },
            { text = "啡", comment = "fei" },
            { text = "绯", comment = "fei" },
            { text = "扉", comment = "fei" },
            { text = "翡", comment = "fei" },
            { text = "腓", comment = "fei" },
            { text = "狒", comment = "fei" },
            { text = "淝", comment = "fei" },
            { text = "蜚", comment = "fei" },
            { text = "痱", comment = "fei" },
            { text = "悱", comment = "fei" },
            { text = "诽", comment = "fei" },
            { text = "榧", comment = "fei" },
            { text = "芾", comment = "fei" },
            { text = "鲱", comment = "fei" },
            { text = "棐", comment = "fei" },
            { text = "剕", comment = "fei" },
            { text = "砩", comment = "fei" },
            { text = "镄", comment = "fei" },
            { text = "朏", comment = "fei" },
            { text = "篚", comment = "fei" },
            { text = "𬴂", comment = "fei" },
        },
        ["fei an"] = {
            { text = "废案", comment = "fei an" },
        },
        ["fei bu"] = {
            { text = "肺部", comment = "fei bu" },
            { text = "飞步", comment = "fei bu" },
        },
        ["fei e"] = {
            { text = "飞蛾", comment = "fei e" },
            { text = "飞鹅", comment = "fei e" },
        },
        ["fei la"] = {
            { text = "菲拉", comment = "fei la" },
        },
        ["fei lai"] = {
            { text = "飞来", comment = "fei lai" },
            { text = "肥来", comment = "fei lai" },
        },
        ["fei li"] = {
            { text = "费力", comment = "fei li" },
            { text = "非礼", comment = "fei li" },
            { text = "菲力", comment = "fei li" },
            { text = "肥力", comment = "fei li" },
            { text = "飞力", comment = "fei li" },
            { text = "飞利", comment = "fei li" },
            { text = "费里", comment = "fei li" },
            { text = "飞离", comment = "fei li" },
            { text = "菲莉", comment = "fei li" },
            { text = "斐丽", comment = "fei li" },
            { text = "飞立", comment = "fei li" },
        },
        ["fei na"] = {
            { text = "菲娜", comment = "fei na" },
            { text = "非那", comment = "fei na" },
            { text = "费娜", comment = "fei na" },
            { text = "飞纳", comment = "fei na" },
        },
        ["fei ou"] = {
            { text = "菲欧", comment = "fei ou" },
            { text = "飞欧", comment = "fei ou" },
            { text = "飞鸥", comment = "fei ou" },
            { text = "菲欧", comment = "fei ou" },
            { text = "飞欧", comment = "fei ou" },
            { text = "飞鸥", comment = "fei ou" },
        },
        ["fei si"] = {
            { text = "肥死", comment = "fei si" },
            { text = "肥四", comment = "fei si" },
            { text = "菲斯", comment = "fei si" },
            { text = "飞思", comment = "fei si" },
            { text = "废丝", comment = "fei si" },
            { text = "飞丝", comment = "fei si" },
            { text = "费斯", comment = "fei si" },
            { text = "费司", comment = "fei si" },
            { text = "肥私", comment = "fei si" },
        },
        ["fei ti"] = {
            { text = "飞踢", comment = "fei ti" },
        },
        ["fei wang"] = {
            { text = "飞往", comment = "fei wang" },
            { text = "飞旺", comment = "fei wang" },
            { text = "啡网", comment = "fei wang" },
            { text = "飞王", comment = "fei wang" },
        },
        ["fei xian"] = {
            { text = "费县", comment = "fei xian" },
            { text = "飞线", comment = "fei xian" },
            { text = "飞仙", comment = "fei xian" },
            { text = "废线", comment = "fei xian" },
            { text = "费显", comment = "fei xian" },
            { text = "非线", comment = "fei xian" },
        },
        ["fei yu"] = {
            { text = "飞羽", comment = "fei yu" },
            { text = "飞鱼", comment = "fei yu" },
            { text = "飞宇", comment = "fei yu" },
            { text = "鲱鱼", comment = "fei yu" },
            { text = "肥鱼", comment = "fei yu" },
            { text = "非鱼", comment = "fei yu" },
            { text = "飞雨", comment = "fei yu" },
            { text = "蜚语", comment = "fei yu" },
            { text = "妃鱼", comment = "fei yu" },
            { text = "肥育", comment = "fei yu" },
            { text = "飞语", comment = "fei yu" },
            { text = "肺腧", comment = "fei yu" },
            { text = "肺鱼", comment = "fei yu" },
            { text = "肥腴", comment = "fei yu" },
        },
        ["fei zai"] = {
            { text = "肥仔", comment = "fei zai" },
            { text = "飞在", comment = "fei zai" },
            { text = "飞仔", comment = "fei zai" },
            { text = "飞灾", comment = "fei zai" },
        },
        ["fen"] = {
            { text = "分", comment = "fen" },
            { text = "粉", comment = "fen" },
            { text = "份", comment = "fen" },
            { text = "芬", comment = "fen" },
            { text = "粪", comment = "fen" },
            { text = "坟", comment = "fen" },
            { text = "奋", comment = "fen" },
            { text = "愤", comment = "fen" },
            { text = "焚", comment = "fen" },
            { text = "纷", comment = "fen" },
            { text = "酚", comment = "fen" },
            { text = "汾", comment = "fen" },
            { text = "氛", comment = "fen" },
            { text = "忿", comment = "fen" },
            { text = "玢", comment = "fen" },
            { text = "吩", comment = "fen" },
            { text = "偾", comment = "fen" },
            { text = "棼", comment = "fen" },
            { text = "棻", comment = "fen" },
            { text = "坋", comment = "fen" },
            { text = "瀵", comment = "fen" },
            { text = "鲼", comment = "fen" },
            { text = "鼢", comment = "fen" },
            { text = "翂", comment = "fen" },
            { text = "豮", comment = "fen" },
            { text = "𣸣", comment = "fen" },
        },
        ["fen bu"] = {
            { text = "分布", comment = "fen bu" },
            { text = "分部", comment = "fen bu" },
            { text = "分步", comment = "fen bu" },
        },
        ["fen ou"] = {
            { text = "芬欧", comment = "fen ou" },
        },
        ["fen si huai"] = {
            { text = "粉丝坏", comment = "fen si huai" },
        },
        ["fen si ri"] = {
            { text = "粉丝日", comment = "fen si ri" },
        },
        ["feng a"] = {
            { text = "风啊", comment = "feng a" },
        },
        ["feng ai"] = {
            { text = "疯爱", comment = "feng ai" },
        },
        ["feng an"] = {
            { text = "丰安", comment = "feng an" },
            { text = "凤安", comment = "feng an" },
        },
        ["feng bu"] = {
            { text = "缝补", comment = "feng bu" },
            { text = "冯部", comment = "feng bu" },
            { text = "风步", comment = "feng bu" },
        },
        ["feng wo"] = {
            { text = "蜂窝", comment = "feng wo" },
            { text = "封我", comment = "feng wo" },
            { text = "丰沃", comment = "feng wo" },
        },
        ["fo"] = {
            { text = "佛", comment = "fo" },
        },
        ["fo ao"] = {
            { text = "佛奥", comment = "fo ao" },
            { text = "佛奥", comment = "fo ao" },
        },
        ["fo bao"] = {
            { text = "佛宝", comment = "fo bao" },
        },
        ["fo bing"] = {
            { text = "佛饼", comment = "fo bing" },
        },
        ["fo ci"] = {
            { text = "佛慈", comment = "fo ci" },
        },
        ["fo da"] = {
            { text = "佛大", comment = "fo da" },
            { text = "佛达", comment = "fo da" },
        },
        ["fo dan"] = {
            { text = "佛诞", comment = "fo dan" },
        },
        ["fo dao"] = {
            { text = "佛道", comment = "fo dao" },
        },
        ["fo de"] = {
            { text = "佛的", comment = "fo de" },
        },
        ["fo deng"] = {
            { text = "佛灯", comment = "fo deng" },
        },
        ["fo dian"] = {
            { text = "佛典", comment = "fo dian" },
            { text = "佛殿", comment = "fo dian" },
        },
        ["fo ding"] = {
            { text = "佛丁", comment = "fo ding" },
        },
        ["fo du"] = {
            { text = "佛都", comment = "fo du" },
        },
        ["fo er"] = {
            { text = "佛尔", comment = "fo er" },
        },
        ["fo fa"] = {
            { text = "佛法", comment = "fo fa" },
        },
        ["fo gang"] = {
            { text = "佛冈", comment = "fo gang" },
            { text = "佛岗", comment = "fo gang" },
        },
        ["fo ge"] = {
            { text = "佛歌", comment = "fo ge" },
        },
        ["fo gu"] = {
            { text = "佛骨", comment = "fo gu" },
        },
        ["fo guang"] = {
            { text = "佛光", comment = "fo guang" },
            { text = "佛广", comment = "fo guang" },
        },
        ["fo guo"] = {
            { text = "佛国", comment = "fo guo" },
        },
        ["fo hai"] = {
            { text = "佛海", comment = "fo hai" },
        },
        ["fo hang"] = {
            { text = "佛航", comment = "fo hang" },
        },
        ["fo hao"] = {
            { text = "佛号", comment = "fo hao" },
        },
        ["fo hua"] = {
            { text = "佛话", comment = "fo hua" },
        },
        ["fo ji"] = {
            { text = "佛偈", comment = "fo ji" },
        },
        ["fo jia"] = {
            { text = "佛家", comment = "fo jia" },
        },
        ["fo jian"] = {
            { text = "佛剑", comment = "fo jian" },
        },
        ["fo jiang"] = {
            { text = "佛江", comment = "fo jiang" },
        },
        ["fo jiao"] = {
            { text = "佛教", comment = "fo jiao" },
            { text = "佛脚", comment = "fo jiao" },
        },
        ["fo jing"] = {
            { text = "佛经", comment = "fo jing" },
        },
        ["fo ju"] = {
            { text = "佛具", comment = "fo ju" },
        },
        ["fo kai"] = {
            { text = "佛开", comment = "fo kai" },
        },
        ["fo kan"] = {
            { text = "佛龛", comment = "fo kan" },
        },
        ["fo ke"] = {
            { text = "佛科", comment = "fo ke" },
        },
        ["fo le"] = {
            { text = "佛了", comment = "fo le" },
        },
        ["fo li"] = {
            { text = "佛理", comment = "fo li" },
            { text = "佛力", comment = "fo li" },
            { text = "佛历", comment = "fo li" },
        },
        ["fo ling"] = {
            { text = "佛岭", comment = "fo ling" },
        },
        ["fo lun"] = {
            { text = "佛伦", comment = "fo lun" },
        },
        ["fo luo"] = {
            { text = "佛罗", comment = "fo luo" },
        },
        ["fo men"] = {
            { text = "佛门", comment = "fo men" },
        },
        ["fo mian"] = {
            { text = "佛面", comment = "fo mian" },
        },
        ["fo mo"] = {
            { text = "佛魔", comment = "fo mo" },
        },
        ["fo mu"] = {
            { text = "佛母", comment = "fo mu" },
        },
        ["fo pai"] = {
            { text = "佛牌", comment = "fo pai" },
        },
        ["fo ping"] = {
            { text = "佛坪", comment = "fo ping" },
        },
        ["fo qi"] = {
            { text = "佛七", comment = "fo qi" },
        },
        ["fo qian"] = {
            { text = "佛前", comment = "fo qian" },
        },
        ["fo qu"] = {
            { text = "佛曲", comment = "fo qu" },
        },
        ["fo ri"] = {
            { text = "佛日", comment = "fo ri" },
        },
        ["fo sha"] = {
            { text = "佛杀", comment = "fo sha" },
            { text = "佛沙", comment = "fo sha" },
        },
        ["fo shan"] = {
            { text = "佛山", comment = "fo shan" },
        },
        ["fo shang"] = {
            { text = "佛商", comment = "fo shang" },
        },
        ["fo shen"] = {
            { text = "佛身", comment = "fo shen" },
        },
        ["fo shi"] = {
            { text = "佛事", comment = "fo shi" },
        },
        ["fo shou"] = {
            { text = "佛手", comment = "fo shou" },
        },
        ["fo si"] = {
            { text = "佛寺", comment = "fo si" },
        },
        ["fo si te"] = {
            { text = "佛斯特", comment = "fo si te" },
        },
        ["fo su"] = {
            { text = "佛塑", comment = "fo su" },
        },
        ["fo ta"] = {
            { text = "佛塔", comment = "fo ta" },
            { text = "佛塔", comment = "fo ta" },
        },
        ["fo tai"] = {
            { text = "佛台", comment = "fo tai" },
            { text = "佛台", comment = "fo tai" },
        },
        ["fo tan"] = {
            { text = "佛昙", comment = "fo tan" },
            { text = "佛昙", comment = "fo tan" },
        },
        ["fo tang"] = {
            { text = "佛堂", comment = "fo tang" },
        },
        ["fo tou"] = {
            { text = "佛头", comment = "fo tou" },
            { text = "佛头", comment = "fo tou" },
        },
        ["fo tu"] = {
            { text = "佛土", comment = "fo tu" },
        },
        ["fo tuo"] = {
            { text = "佛陀", comment = "fo tuo" },
            { text = "佛陀", comment = "fo tuo" },
        },
        ["fo xi"] = {
            { text = "佛系", comment = "fo xi" },
            { text = "佛西", comment = "fo xi" },
        },
        ["fo xiang"] = {
            { text = "佛像", comment = "fo xiang" },
        },
        ["fo xiao"] = {
            { text = "佛晓", comment = "fo xiao" },
        },
        ["fo xie"] = {
            { text = "佛协", comment = "fo xie" },
        },
        ["fo xin"] = {
            { text = "佛心", comment = "fo xin" },
        },
        ["fo xing"] = {
            { text = "佛性", comment = "fo xing" },
        },
        ["fo xiu"] = {
            { text = "佛秀", comment = "fo xiu" },
        },
        ["fo xue"] = {
            { text = "佛学", comment = "fo xue" },
        },
        ["fo ya"] = {
            { text = "佛牙", comment = "fo ya" },
        },
        ["fo yan"] = {
            { text = "佛言", comment = "fo yan" },
            { text = "佛言", comment = "fo yan" },
        },
        ["fo ye"] = {
            { text = "佛爷", comment = "fo ye" },
            { text = "佛爷", comment = "fo ye" },
        },
        ["fo yin"] = {
            { text = "佛印", comment = "fo yin" },
            { text = "佛音", comment = "fo yin" },
            { text = "佛印", comment = "fo yin" },
            { text = "佛音", comment = "fo yin" },
        },
        ["fo you"] = {
            { text = "佛友", comment = "fo you" },
            { text = "佛友", comment = "fo you" },
        },
        ["fo yu"] = {
            { text = "佛语", comment = "fo yu" },
            { text = "佛语", comment = "fo yu" },
        },
        ["fo yuan"] = {
            { text = "佛缘", comment = "fo yuan" },
            { text = "佛缘", comment = "fo yuan" },
        },
        ["fo yue"] = {
            { text = "佛曰", comment = "fo yue" },
        },
        ["fo zhao"] = {
            { text = "佛照", comment = "fo zhao" },
            { text = "佛肇", comment = "fo zhao" },
        },
        ["fo zhi"] = {
            { text = "佛职", comment = "fo zhi" },
        },
        ["fo zhong"] = {
            { text = "佛中", comment = "fo zhong" },
        },
        ["fo zhou"] = {
            { text = "佛州", comment = "fo zhou" },
        },
        ["fo zhu"] = {
            { text = "佛珠", comment = "fo zhu" },
            { text = "佛主", comment = "fo zhu" },
        },
        ["fo zi"] = {
            { text = "佛子", comment = "fo zi" },
        },
        ["fou"] = {
            { text = "否", comment = "fou" },
            { text = "缶", comment = "fou" },
            { text = "不", comment = "fou" },
            { text = "垺", comment = "fou" },
            { text = "衃", comment = "fou" },
        },
        ["fou shi"] = {
            { text = "否是", comment = "fou shi" },
        },
        ["fu a"] = {
            { text = "付啊", comment = "fu a" },
        },
        ["fu ai"] = {
            { text = "父爱", comment = "fu ai" },
            { text = "抚爱", comment = "fu ai" },
            { text = "福爱", comment = "fu ai" },
        },
        ["fu an"] = {
            { text = "福安", comment = "fu an" },
            { text = "富安", comment = "fu an" },
            { text = "伏案", comment = "fu an" },
            { text = "伏安", comment = "fu an" },
            { text = "阜安", comment = "fu an" },
            { text = "赋安", comment = "fu an" },
            { text = "腹案", comment = "fu an" },
            { text = "负案", comment = "fu an" },
        },
        ["fu ang"] = {
            { text = "付昂", comment = "fu ang" },
        },
        ["fu bu"] = {
            { text = "腹部", comment = "fu bu" },
            { text = "副部", comment = "fu bu" },
            { text = "服部", comment = "fu bu" },
            { text = "福步", comment = "fu bu" },
        },
        ["fu bu ji"] = {
            { text = "副部级", comment = "fu bu ji" },
        },
        ["fu di"] = {
            { text = "府邸", comment = "fu di" },
            { text = "福地", comment = "fu di" },
            { text = "复地", comment = "fu di" },
            { text = "腹地", comment = "fu di" },
            { text = "富迪", comment = "fu di" },
            { text = "伏地", comment = "fu di" },
            { text = "复底", comment = "fu di" },
            { text = "富地", comment = "fu di" },
            { text = "福邸", comment = "fu di" },
            { text = "福迪", comment = "fu di" },
            { text = "府第", comment = "fu di" },
            { text = "付迪", comment = "fu di" },
            { text = "赴敌", comment = "fu di" },
        },
        ["fu en"] = {
            { text = "弗恩", comment = "fu en" },
            { text = "福恩", comment = "fu en" },
        },
        ["fu hua an"] = {
            { text = "氟化铵", comment = "fu hua an" },
        },
        ["fu hua bu"] = {
            { text = "孵化部", comment = "fu hua bu" },
        },
        ["fu huai"] = {
            { text = "腐坏", comment = "fu huai" },
        },
        ["fu o"] = {
            { text = "富哦", comment = "fu o" },
        },
        ["fu ou"] = {
            { text = "赴欧", comment = "fu ou" },
            { text = "佛欧", comment = "fu ou" },
        },
        ["fu ou ji"] = {
            { text = "福偶记", comment = "fu ou ji" },
        },
        ["fu ran"] = {
            { text = "复燃", comment = "fu ran" },
            { text = "付然", comment = "fu ran" },
            { text = "富然", comment = "fu ran" },
            { text = "怫然", comment = "fu ran" },
            { text = "佛燃", comment = "fu ran" },
        },
        ["fu ri"] = {
            { text = "赴日", comment = "fu ri" },
            { text = "孚日", comment = "fu ri" },
            { text = "富日", comment = "fu ri" },
            { text = "福日", comment = "fu ri" },
        },
        ["fu rou"] = {
            { text = "腐肉", comment = "fu rou" },
        },
        ["ga ba"] = {
            { text = "嘎巴", comment = "ga ba" },
        },
        ["ga bo"] = {
            { text = "伽柏", comment = "ga bo" },
        },
        ["ga na"] = {
            { text = "戛纳", comment = "ga na" },
        },
        ["ga you"] = {
            { text = "噶油", comment = "ga you" },
        },
        ["gai bu"] = {
            { text = "改不", comment = "gai bu" },
            { text = "概不", comment = "gai bu" },
            { text = "盖布", comment = "gai bu" },
            { text = "改补", comment = "gai bu" },
            { text = "该部", comment = "gai bu" },
        },
        ["gai ou"] = {
            { text = "盖欧", comment = "gai ou" },
        },
        ["gan a"] = {
            { text = "干啊", comment = "gan a" },
        },
        ["gan bu"] = {
            { text = "干部", comment = "gan bu" },
            { text = "干不", comment = "gan bu" },
            { text = "敢不", comment = "gan bu" },
            { text = "干布", comment = "gan bu" },
            { text = "肝部", comment = "gan bu" },
            { text = "赶不", comment = "gan bu" },
        },
        ["gan ou"] = {
            { text = "干呕", comment = "gan ou" },
        },
        ["gao a"] = {
            { text = "高啊", comment = "gao a" },
            { text = "搞啊", comment = "gao a" },
        },
        ["gao bu"] = {
            { text = "搞不", comment = "gao bu" },
            { text = "高埗", comment = "gao bu" },
            { text = "高步", comment = "gao bu" },
            { text = "高不", comment = "gao bu" },
            { text = "皋埠", comment = "gao bu" },
            { text = "高补", comment = "gao bu" },
        },
        ["gao huai"] = {
            { text = "搞坏", comment = "gao huai" },
        },
        ["gao o"] = {
            { text = "高哦", comment = "gao o" },
        },
        ["gao ou"] = {
            { text = "搞偶", comment = "gao ou" },
        },
        ["gao ri"] = {
            { text = "高日", comment = "gao ri" },
        },
        ["ge bu"] = {
            { text = "各部", comment = "ge bu" },
            { text = "葛布", comment = "ge bu" },
            { text = "格布", comment = "ge bu" },
            { text = "个不", comment = "ge bu" },
            { text = "割补", comment = "ge bu" },
        },
        ["ge li dao"] = {
            { text = "蛤蜊岛", comment = "ge li dao" },
        },
        ["ge lie fo"] = {
            { text = "格列佛", comment = "ge lie fo" },
        },
        ["ge nan"] = {
            { text = "葛楠", comment = "ge nan" },
        },
        ["ge nuo"] = {
            { text = "格诺", comment = "ge nuo" },
        },
        ["ge ou"] = {
            { text = "格欧", comment = "ge ou" },
        },
        ["ge tai"] = {
            { text = "各台", comment = "ge tai" },
            { text = "割台", comment = "ge tai" },
            { text = "格泰", comment = "ge tai" },
            { text = "个态", comment = "ge tai" },
        },
        ["ge tan"] = {
            { text = "哥谭", comment = "ge tan" },
            { text = "歌坛", comment = "ge tan" },
        },
        ["ge tie"] = {
            { text = "铬铁", comment = "ge tie" },
        },
        ["ge tou"] = {
            { text = "个头", comment = "ge tou" },
            { text = "歌头", comment = "ge tou" },
        },
        ["ge tuan"] = {
            { text = "个团", comment = "ge tuan" },
        },
        ["ge ya"] = {
            { text = "个呀", comment = "ge ya" },
            { text = "哥呀", comment = "ge ya" },
            { text = "硌牙", comment = "ge ya" },
            { text = "格雅", comment = "ge ya" },
            { text = "戈雅", comment = "ge ya" },
            { text = "戈娅", comment = "ge ya" },
        },
        ["ge yan"] = {
            { text = "格言", comment = "ge yan" },
            { text = "葛燕", comment = "ge yan" },
            { text = "葛艳", comment = "ge yan" },
            { text = "葛岩", comment = "ge yan" },
        },
        ["ge ye"] = {
            { text = "隔夜", comment = "ge ye" },
            { text = "各业", comment = "ge ye" },
            { text = "葛叶", comment = "ge ye" },
            { text = "哥也", comment = "ge ye" },
            { text = "鸽业", comment = "ge ye" },
        },
        ["ge yin"] = {
            { text = "隔音", comment = "ge yin" },
            { text = "歌吟", comment = "ge yin" },
        },
        ["ge you"] = {
            { text = "各有", comment = "ge you" },
            { text = "葛优", comment = "ge you" },
            { text = "隔油", comment = "ge you" },
            { text = "个有", comment = "ge you" },
            { text = "歌友", comment = "ge you" },
            { text = "个油", comment = "ge you" },
            { text = "鸽友", comment = "ge you" },
            { text = "格优", comment = "ge you" },
            { text = "哥有", comment = "ge you" },
        },
        ["ge you qi"] = {
            { text = "隔油器", comment = "ge you qi" },
        },
        ["ge yuan"] = {
            { text = "各院", comment = "ge yuan" },
            { text = "各园", comment = "ge yuan" },
            { text = "个园", comment = "ge yuan" },
            { text = "葛源", comment = "ge yuan" },
            { text = "阁员", comment = "ge yuan" },
            { text = "哥远", comment = "ge yuan" },
        },
        ["ge yue"] = {
            { text = "个月", comment = "ge yue" },
            { text = "各月", comment = "ge yue" },
            { text = "隔月", comment = "ge yue" },
            { text = "革月", comment = "ge yue" },
        },
        ["gei a"] = {
            { text = "给啊", comment = "gei a" },
        },
        ["gei an"] = {
            { text = "给俺", comment = "gei an" },
        },
        ["gei bu"] = {
            { text = "给不", comment = "gei bu" },
            { text = "给补", comment = "gei bu" },
        },
        ["gei bu qi"] = {
            { text = "给不起", comment = "gei bu qi" },
        },
        ["gei e"] = {
            { text = "给哦", comment = "gei e" },
        },
        ["gei ne"] = {
            { text = "给呢", comment = "gei ne" },
        },
        ["gei ou"] = {
            { text = "给偶", comment = "gei ou" },
            { text = "给偶", comment = "gei ou" },
        },
        ["gei yu"] = {
            { text = "给与", comment = "gei yu" },
            { text = "给于", comment = "gei yu" },
        },
        ["gen an"] = {
            { text = "跟俺", comment = "gen an" },
        },
        ["gen wo"] = {
            { text = "跟我", comment = "gen wo" },
        },
        ["geng ai"] = {
            { text = "更爱", comment = "geng ai" },
        },
        ["geng an"] = {
            { text = "更暗", comment = "geng an" },
        },
        ["geng bu"] = {
            { text = "更不", comment = "geng bu" },
        },
        ["geng huai"] = {
            { text = "更坏", comment = "geng huai" },
        },
        ["geng ri"] = {
            { text = "庚日", comment = "geng ri" },
        },
        ["geng xu"] = {
            { text = "赓续", comment = "geng xu" },
            { text = "更需", comment = "geng xu" },
            { text = "庚戌", comment = "geng xu" },
            { text = "耿旭", comment = "geng xu" },
        },
        ["geng ye"] = {
            { text = "哽咽", comment = "geng ye" },
            { text = "哽噎", comment = "geng ye" },
            { text = "梗咽", comment = "geng ye" },
        },
        ["gong ao"] = {
            { text = "宫傲", comment = "gong ao" },
        },
        ["gong bu"] = {
            { text = "公布", comment = "gong bu" },
            { text = "工部", comment = "gong bu" },
            { text = "弓步", comment = "gong bu" },
            { text = "工步", comment = "gong bu" },
            { text = "拱部", comment = "gong bu" },
            { text = "贡布", comment = "gong bu" },
            { text = "公补", comment = "gong bu" },
            { text = "唝吥", comment = "gong bu" },
        },
        ["gong fo"] = {
            { text = "供佛", comment = "gong fo" },
        },
        ["gong ji tou"] = {
            { text = "公鸡头", comment = "gong ji tou" },
            { text = "攻击头", comment = "gong ji tou" },
        },
        ["gong jing bu"] = {
            { text = "工经部", comment = "gong jing bu" },
        },
        ["gong ou"] = {
            { text = "共欧", comment = "gong ou" },
            { text = "宫欧", comment = "gong ou" },
        },
        ["gu ao"] = {
            { text = "孤傲", comment = "gu ao" },
            { text = "古奥", comment = "gu ao" },
        },
        ["gu ba"] = {
            { text = "古巴", comment = "gu ba" },
            { text = "股吧", comment = "gu ba" },
            { text = "古坝", comment = "gu ba" },
            { text = "鼓吧", comment = "gu ba" },
        },
        ["gu bai"] = {
            { text = "古柏", comment = "gu bai" },
            { text = "骨白", comment = "gu bai" },
            { text = "顾白", comment = "gu bai" },
        },
        ["gu ban"] = {
            { text = "古板", comment = "gu ban" },
            { text = "骨板", comment = "gu ban" },
        },
        ["gu bang"] = {
            { text = "鼓棒", comment = "gu bang" },
            { text = "固邦", comment = "gu bang" },
            { text = "骨棒", comment = "gu bang" },
            { text = "谷邦", comment = "gu bang" },
        },
        ["gu bao"] = {
            { text = "鼓包", comment = "gu bao" },
            { text = "古堡", comment = "gu bao" },
            { text = "古宝", comment = "gu bao" },
        },
        ["gu bei"] = {
            { text = "古北", comment = "gu bei" },
            { text = "顾北", comment = "gu bei" },
            { text = "古碑", comment = "gu bei" },
            { text = "古贝", comment = "gu bei" },
        },
        ["gu ben"] = {
            { text = "股本", comment = "gu ben" },
            { text = "固本", comment = "gu ben" },
            { text = "孤本", comment = "gu ben" },
        },
        ["gu bin"] = {
            { text = "顾斌", comment = "gu bin" },
            { text = "顾彬", comment = "gu bin" },
            { text = "谷斌", comment = "gu bin" },
        },
        ["gu bu"] = {
            { text = "股部", comment = "gu bu" },
            { text = "谷埠", comment = "gu bu" },
        },
        ["gu fo"] = {
            { text = "古佛", comment = "gu fo" },
        },
        ["gu na"] = {
            { text = "古娜", comment = "gu na" },
            { text = "谷娜", comment = "gu na" },
        },
        ["gu ou"] = {
            { text = "古偶", comment = "gu ou" },
        },
        ["gu ya"] = {
            { text = "古雅", comment = "gu ya" },
            { text = "谷芽", comment = "gu ya" },
            { text = "箍牙", comment = "gu ya" },
        },
        ["gu yan"] = {
            { text = "孤雁", comment = "gu yan" },
            { text = "古言", comment = "gu yan" },
            { text = "顾艳", comment = "gu yan" },
            { text = "顾燕", comment = "gu yan" },
            { text = "孤烟", comment = "gu yan" },
            { text = "顾言", comment = "gu yan" },
            { text = "古岩", comment = "gu yan" },
            { text = "谷岩", comment = "gu yan" },
            { text = "顾岩", comment = "gu yan" },
            { text = "顾炎", comment = "gu yan" },
            { text = "顾妍", comment = "gu yan" },
            { text = "谷言", comment = "gu yan" },
            { text = "古谚", comment = "gu yan" },
            { text = "瞽言", comment = "gu yan" },
            { text = "箍眼", comment = "gu yan" },
        },
        ["gu yao"] = {
            { text = "古窑", comment = "gu yao" },
            { text = "顾瑶", comment = "gu yao" },
        },
        ["gu ye"] = {
            { text = "姑爷", comment = "gu ye" },
            { text = "古冶", comment = "gu ye" },
            { text = "固液", comment = "gu ye" },
            { text = "钴业", comment = "gu ye" },
            { text = "顾烨", comment = "gu ye" },
            { text = "顾晔", comment = "gu ye" },
        },
        ["gu yin"] = {
            { text = "古音", comment = "gu yin" },
            { text = "古银", comment = "gu yin" },
        },
        ["gu you"] = {
            { text = "固有", comment = "gu you" },
            { text = "古有", comment = "gu you" },
            { text = "股友", comment = "gu you" },
            { text = "故友", comment = "gu you" },
            { text = "故有", comment = "gu you" },
            { text = "谷优", comment = "gu you" },
        },
        ["gu yuan"] = {
            { text = "雇员", comment = "gu yuan" },
            { text = "固原", comment = "gu yuan" },
            { text = "沽源", comment = "gu yuan" },
            { text = "故园", comment = "gu yuan" },
            { text = "故渊", comment = "gu yuan" },
            { text = "顾源", comment = "gu yuan" },
            { text = "固元", comment = "gu yuan" },
            { text = "古猿", comment = "gu yuan" },
            { text = "古原", comment = "gu yuan" },
            { text = "固源", comment = "gu yuan" },
            { text = "顾远", comment = "gu yuan" },
            { text = "古元", comment = "gu yuan" },
            { text = "顾渊", comment = "gu yuan" },
            { text = "古远", comment = "gu yuan" },
        },
        ["gu yue"] = {
            { text = "古月", comment = "gu yue" },
            { text = "古越", comment = "gu yue" },
            { text = "古乐", comment = "gu yue" },
            { text = "孤月", comment = "gu yue" },
            { text = "鼓乐", comment = "gu yue" },
            { text = "故曰", comment = "gu yue" },
            { text = "顾悦", comment = "gu yue" },
            { text = "谷月", comment = "gu yue" },
            { text = "谷悦", comment = "gu yue" },
            { text = "顾越", comment = "gu yue" },
            { text = "谷岳", comment = "gu yue" },
        },
        ["gu yun"] = {
            { text = "古韵", comment = "gu yun" },
            { text = "古云", comment = "gu yun" },
            { text = "孤云", comment = "gu yun" },
            { text = "顾云", comment = "gu yun" },
            { text = "顾昀", comment = "gu yun" },
            { text = "古运", comment = "gu yun" },
            { text = "谷云", comment = "gu yun" },
        },
        ["gua niu"] = {
            { text = "瓜牛", comment = "gua niu" },
        },
        ["gua tai"] = {
            { text = "寡肽", comment = "gua tai" },
            { text = "呱太", comment = "gua tai" },
            { text = "挂台", comment = "gua tai" },
        },
        ["gua tan"] = {
            { text = "挂毯", comment = "gua tan" },
        },
        ["gua tie"] = {
            { text = "挂贴", comment = "gua tie" },
        },
        ["gua tou"] = {
            { text = "寡头", comment = "gua tou" },
        },
        ["gua tuan"] = {
            { text = "挂团", comment = "gua tuan" },
        },
        ["gua ya"] = {
            { text = "瓜亚", comment = "gua ya" },
        },
        ["gua ye"] = {
            { text = "挂野", comment = "gua ye" },
        },
        ["gua yin"] = {
            { text = "挂印", comment = "gua yin" },
        },
        ["gua you"] = {
            { text = "刮油", comment = "gua you" },
            { text = "瓜游", comment = "gua you" },
        },
        ["gua yun"] = {
            { text = "挂云", comment = "gua yun" },
        },
        ["guai a"] = {
            { text = "乖啊", comment = "guai a" },
        },
        ["guai bu"] = {
            { text = "怪不", comment = "guai bu" },
        },
        ["guai e"] = {
            { text = "乖哦", comment = "guai e" },
        },
        ["guai nv"] = {
            { text = "乖女", comment = "guai nv" },
        },
        ["guai yu"] = {
            { text = "怪鱼", comment = "guai yu" },
        },
        ["guan huai"] = {
            { text = "关怀", comment = "guan huai" },
            { text = "惯坏", comment = "guan huai" },
        },
        ["guan ri"] = {
            { text = "贯日", comment = "guan ri" },
        },
        ["guan yu"] = {
            { text = "关于", comment = "guan yu" },
            { text = "关羽", comment = "guan yu" },
            { text = "冠宇", comment = "guan yu" },
            { text = "冠寓", comment = "guan yu" },
            { text = "惯于", comment = "guan yu" },
            { text = "关宇", comment = "guan yu" },
            { text = "观鱼", comment = "guan yu" },
            { text = "冠玉", comment = "guan yu" },
            { text = "冠誉", comment = "guan yu" },
            { text = "冠羽", comment = "guan yu" },
            { text = "观宇", comment = "guan yu" },
            { text = "关於", comment = "guan yu" },
        },
        ["guang ai"] = {
            { text = "广爱", comment = "guang ai" },
        },
        ["guang an"] = {
            { text = "广安", comment = "guang an" },
            { text = "光暗", comment = "guang an" },
        },
        ["guang ao"] = {
            { text = "广澳", comment = "guang ao" },
            { text = "广奥", comment = "guang ao" },
        },
        ["guang bu"] = {
            { text = "广布", comment = "guang bu" },
        },
        ["guang fo"] = {
            { text = "广佛", comment = "guang fo" },
        },
        ["guang huai"] = {
            { text = "广怀", comment = "guang huai" },
        },
        ["guang ou"] = {
            { text = "光耦", comment = "guang ou" },
        },
        ["guang ri"] = {
            { text = "广日", comment = "guang ri" },
        },
        ["guang xu"] = {
            { text = "光绪", comment = "guang xu" },
            { text = "广旭", comment = "guang xu" },
            { text = "光旭", comment = "guang xu" },
        },
        ["guang ye"] = {
            { text = "广业", comment = "guang ye" },
            { text = "广野", comment = "guang ye" },
            { text = "光夜", comment = "guang ye" },
        },
        ["gui a"] = {
            { text = "贵啊", comment = "gui a" },
            { text = "鬼啊", comment = "gui a" },
        },
        ["gui an"] = {
            { text = "跪安", comment = "gui an" },
            { text = "贵安", comment = "gui an" },
            { text = "归案", comment = "gui an" },
            { text = "桂安", comment = "gui an" },
        },
        ["gui ao"] = {
            { text = "鬼獒", comment = "gui ao" },
        },
        ["gui bu"] = {
            { text = "贵部", comment = "gui bu" },
            { text = "贵不", comment = "gui bu" },
            { text = "鬼步", comment = "gui bu" },
        },
        ["gui e"] = {
            { text = "贵哦", comment = "gui e" },
        },
        ["gui ne"] = {
            { text = "鬼呢", comment = "gui ne" },
        },
        ["gui nv"] = {
            { text = "闺女", comment = "gui nv" },
            { text = "贵女", comment = "gui nv" },
            { text = "鬼女", comment = "gui nv" },
        },
        ["gui xu"] = {
            { text = "归墟", comment = "gui xu" },
        },
        ["gui yu"] = {
            { text = "归于", comment = "gui yu" },
            { text = "桂鱼", comment = "gui yu" },
            { text = "鲑鱼", comment = "gui yu" },
            { text = "鳜鱼", comment = "gui yu" },
            { text = "鬼蜮", comment = "gui yu" },
            { text = "桂语", comment = "gui yu" },
            { text = "贵屿", comment = "gui yu" },
            { text = "桂玉", comment = "gui yu" },
            { text = "贵宇", comment = "gui yu" },
        },
        ["gun a"] = {
            { text = "滚啊", comment = "gun a" },
        },
        ["guo a"] = {
            { text = "过啊", comment = "guo a" },
        },
        ["guo ai"] = {
            { text = "国哀", comment = "guo ai" },
            { text = "郭爱", comment = "guo ai" },
            { text = "国爱", comment = "guo ai" },
        },
        ["guo an"] = {
            { text = "国安", comment = "guo an" },
            { text = "郭安", comment = "guo an" },
            { text = "国岸", comment = "guo an" },
        },
        ["guo ang"] = {
            { text = "郭昂", comment = "guo ang" },
        },
        ["guo ao"] = {
            { text = "国奥", comment = "guo ao" },
            { text = "郭奥", comment = "guo ao" },
        },
        ["guo di"] = {
            { text = "过低", comment = "guo di" },
            { text = "锅底", comment = "guo di" },
            { text = "郭迪", comment = "guo di" },
            { text = "果地", comment = "guo di" },
        },
        ["guo en"] = {
            { text = "国恩", comment = "guo en" },
        },
        ["guo huai"] = {
            { text = "国槐", comment = "guo huai" },
            { text = "郭淮", comment = "guo huai" },
        },
        ["guo ri"] = {
            { text = "果日", comment = "guo ri" },
        },
        ["guo yu"] = {
            { text = "过于", comment = "guo yu" },
            { text = "国语", comment = "guo yu" },
            { text = "郭宇", comment = "guo yu" },
            { text = "国宇", comment = "guo yu" },
            { text = "国誉", comment = "guo yu" },
            { text = "郭玉", comment = "guo yu" },
            { text = "国玉", comment = "guo yu" },
            { text = "郭雨", comment = "guo yu" },
            { text = "过誉", comment = "guo yu" },
            { text = "国裕", comment = "guo yu" },
            { text = "郭瑜", comment = "guo yu" },
            { text = "郭钰", comment = "guo yu" },
            { text = "郭语", comment = "guo yu" },
            { text = "郭煜", comment = "guo yu" },
            { text = "国羽", comment = "guo yu" },
            { text = "郭羽", comment = "guo yu" },
            { text = "果语", comment = "guo yu" },
            { text = "郭昱", comment = "guo yu" },
            { text = "郭禹", comment = "guo yu" },
            { text = "过於", comment = "guo yu" },
            { text = "过逾", comment = "guo yu" },
        },
        ["ha a a"] = {
            { text = "哈啊啊", comment = "ha a a" },
        },
        ["ha ao"] = {
            { text = "哈奥", comment = "ha ao" },
        },
        ["ha ba"] = {
            { text = "哈巴", comment = "ha ba" },
        },
        ["ha ban"] = {
            { text = "哈板", comment = "ha ban" },
        },
        ["ha bao"] = {
            { text = "哈宝", comment = "ha bao" },
        },
        ["ha bei"] = {
            { text = "哈贝", comment = "ha bei" },
            { text = "哈北", comment = "ha bei" },
        },
        ["ha ben"] = {
            { text = "哈本", comment = "ha ben" },
        },
        ["ha bo"] = {
            { text = "哈珀", comment = "ha bo" },
            { text = "哈勃", comment = "ha bo" },
            { text = "哈博", comment = "ha bo" },
        },
        ["ha bu"] = {
            { text = "哈布", comment = "ha bu" },
        },
        ["ha fa"] = {
            { text = "哈法", comment = "ha fa" },
        },
        ["ha fo"] = {
            { text = "哈佛", comment = "ha fo" },
        },
        ["ha na"] = {
            { text = "哈娜", comment = "ha na" },
            { text = "哈拿", comment = "ha na" },
        },
        ["ha nan"] = {
            { text = "哈南", comment = "ha nan" },
        },
        ["ha nei"] = {
            { text = "哈内", comment = "ha nei" },
        },
        ["ha niu"] = {
            { text = "哈牛", comment = "ha niu" },
        },
        ["ha ou"] = {
            { text = "哈偶", comment = "ha ou" },
        },
        ["ha tie"] = {
            { text = "哈铁", comment = "ha tie" },
        },
        ["ha tou"] = {
            { text = "哈投", comment = "ha tou" },
        },
        ["ha yao"] = {
            { text = "哈药", comment = "ha yao" },
            { text = "哈腰", comment = "ha yao" },
            { text = "哈要", comment = "ha yao" },
        },
        ["ha ye"] = {
            { text = "哈耶", comment = "ha ye" },
        },
        ["ha yin"] = {
            { text = "哈银", comment = "ha yin" },
        },
        ["ha you"] = {
            { text = "哈游", comment = "ha you" },
            { text = "哈有", comment = "ha you" },
        },
        ["ha yuan"] = {
            { text = "哈院", comment = "ha yuan" },
            { text = "哈院", comment = "ha yuan" },
        },
        ["hai ao"] = {
            { text = "海奥", comment = "hai ao" },
        },
        ["hai bu"] = {
            { text = "还不", comment = "hai bu" },
            { text = "还补", comment = "hai bu" },
            { text = "海捕", comment = "hai bu" },
            { text = "海布", comment = "hai bu" },
        },
        ["hai bu dao"] = {
            { text = "还不到", comment = "hai bu dao" },
        },
        ["hai bu dian"] = {
            { text = "还不点", comment = "hai bu dian" },
        },
        ["hai bu hui"] = {
            { text = "还不会", comment = "hai bu hui" },
            { text = "还不回", comment = "hai bu hui" },
        },
        ["hai bu wan"] = {
            { text = "还不晚", comment = "hai bu wan" },
            { text = "还不完", comment = "hai bu wan" },
        },
        ["hai e"] = {
            { text = "还饿", comment = "hai e" },
            { text = "还哦", comment = "hai e" },
        },
        ["hai huai"] = {
            { text = "还坏", comment = "hai huai" },
        },
        ["hai me you"] = {
            { text = "还么有", comment = "hai me you" },
        },
        ["hai mei ou"] = {
            { text = "还没偶", comment = "hai mei ou" },
        },
        ["hai ou"] = {
            { text = "海鸥", comment = "hai ou" },
            { text = "海欧", comment = "hai ou" },
            { text = "海鸥", comment = "hai ou" },
            { text = "海欧", comment = "hai ou" },
        },
        ["hai ou dao"] = {
            { text = "海鸥岛", comment = "hai ou dao" },
        },
        ["hai ou dian"] = {
            { text = "海鸥点", comment = "hai ou dian" },
        },
        ["hai ou hui"] = {
            { text = "海鸥灰", comment = "hai ou hui" },
        },
        ["hai ou wan"] = {
            { text = "海鸥湾", comment = "hai ou wan" },
        },
        ["hai ri"] = {
            { text = "海日", comment = "hai ri" },
        },
        ["hai xu"] = {
            { text = "还需", comment = "hai xu" },
            { text = "海旭", comment = "hai xu" },
            { text = "还须", comment = "hai xu" },
        },
        ["hai yu"] = {
            { text = "海域", comment = "hai yu" },
            { text = "还与", comment = "hai yu" },
            { text = "海鱼", comment = "hai yu" },
            { text = "还余", comment = "hai yu" },
            { text = "海宇", comment = "hai yu" },
            { text = "海玉", comment = "hai yu" },
            { text = "海虞", comment = "hai yu" },
            { text = "海芋", comment = "hai yu" },
            { text = "海裕", comment = "hai yu" },
            { text = "海誉", comment = "hai yu" },
            { text = "海语", comment = "hai yu" },
            { text = "海钰", comment = "hai yu" },
            { text = "海榆", comment = "hai yu" },
            { text = "海御", comment = "hai yu" },
            { text = "海隅", comment = "hai yu" },
        },
        ["han a"] = {
            { text = "汗啊", comment = "han a" },
        },
        ["han an"] = {
            { text = "汉安", comment = "han an" },
        },
        ["han bu"] = {
            { text = "汗布", comment = "han bu" },
            { text = "焊补", comment = "han bu" },
            { text = "韩部", comment = "han bu" },
        },
        ["han di"] = {
            { text = "旱地", comment = "han di" },
            { text = "寒地", comment = "han di" },
            { text = "韩迪", comment = "han di" },
            { text = "汉地", comment = "han di" },
            { text = "汉迪", comment = "han di" },
        },
        ["han ou"] = {
            { text = "汉欧", comment = "han ou" },
        },
        ["han yu"] = {
            { text = "汉语", comment = "han yu" },
            { text = "韩语", comment = "han yu" },
            { text = "韩愈", comment = "han yu" },
            { text = "韩宇", comment = "han yu" },
            { text = "瀚宇", comment = "han yu" },
            { text = "韩玉", comment = "han yu" },
            { text = "韩娱", comment = "han yu" },
            { text = "韩雨", comment = "han yu" },
            { text = "涵宇", comment = "han yu" },
            { text = "寒玉", comment = "han yu" },
            { text = "韩瑜", comment = "han yu" },
            { text = "汉宇", comment = "han yu" },
            { text = "韩钰", comment = "han yu" },
            { text = "寒雨", comment = "han yu" },
            { text = "翰宇", comment = "han yu" },
            { text = "韩煜", comment = "han yu" },
            { text = "韩羽", comment = "han yu" },
            { text = "含玉", comment = "han yu" },
            { text = "涵予", comment = "han yu" },
            { text = "涵钰", comment = "han yu" },
            { text = "涵玉", comment = "han yu" },
            { text = "韩禹", comment = "han yu" },
            { text = "韩昱", comment = "han yu" },
            { text = "捍御", comment = "han yu" },
        },
        ["hang bu"] = {
            { text = "杭埠", comment = "hang bu" },
            { text = "航埠", comment = "hang bu" },
            { text = "行不", comment = "hang bu" },
        },
        ["hang ye"] = {
            { text = "行业", comment = "hang ye" },
        },
        ["hao a"] = {
            { text = "好啊", comment = "hao a" },
            { text = "号啊", comment = "hao a" },
        },
        ["hao an"] = {
            { text = "毫安", comment = "hao an" },
            { text = "好暗", comment = "hao an" },
            { text = "浩安", comment = "hao an" },
            { text = "昊安", comment = "hao an" },
        },
        ["hao ao"] = {
            { text = "好奥", comment = "hao ao" },
            { text = "好嗷", comment = "hao ao" },
        },
        ["hao ba ba"] = {
            { text = "好爸爸", comment = "hao ba ba" },
        },
        ["hao bao a"] = {
            { text = "好饱啊", comment = "hao bao a" },
        },
        ["hao bu"] = {
            { text = "好不", comment = "hao bu" },
            { text = "毫不", comment = "hao bu" },
            { text = "好补", comment = "hao bu" },
            { text = "号布", comment = "hao bu" },
        },
        ["hao da"] = {
            { text = "好大", comment = "hao da" },
            { text = "好哒", comment = "hao da" },
            { text = "好打", comment = "hao da" },
            { text = "浩大", comment = "hao da" },
            { text = "好搭", comment = "hao da" },
            { text = "好嗒", comment = "hao da" },
            { text = "浩达", comment = "hao da" },
            { text = "昊达", comment = "hao da" },
            { text = "豪大", comment = "hao da" },
            { text = "豪达", comment = "hao da" },
            { text = "灏达", comment = "hao da" },
        },
        ["hao di"] = {
            { text = "好滴", comment = "hao di" },
            { text = "好低", comment = "hao di" },
            { text = "号地", comment = "hao di" },
            { text = "好地", comment = "hao di" },
            { text = "好睇", comment = "hao di" },
            { text = "好迪", comment = "hao di" },
            { text = "豪迪", comment = "hao di" },
            { text = "浩迪", comment = "hao di" },
            { text = "郝迪", comment = "hao di" },
            { text = "浩弟", comment = "hao di" },
            { text = "豪弟", comment = "hao di" },
        },
        ["hao e a"] = {
            { text = "好饿啊", comment = "hao e a" },
        },
        ["hao ei"] = {
            { text = "好诶", comment = "hao ei" },
        },
        ["hao en"] = {
            { text = "豪恩", comment = "hao en" },
            { text = "浩恩", comment = "hao en" },
        },
        ["hao huai"] = {
            { text = "好坏", comment = "hao huai" },
        },
        ["hao le ya"] = {
            { text = "好了呀", comment = "hao le ya" },
        },
        ["hao lei a"] = {
            { text = "好累啊", comment = "hao lei a" },
        },
        ["hao o"] = {
            { text = "好哦", comment = "hao o" },
            { text = "好噢", comment = "hao o" },
        },
        ["hao ou"] = {
            { text = "毫欧", comment = "hao ou" },
            { text = "好欧", comment = "hao ou" },
            { text = "浩欧", comment = "hao ou" },
        },
        ["hao ri"] = {
            { text = "好日", comment = "hao ri" },
        },
        ["hao xia tou"] = {
            { text = "好下头", comment = "hao xia tou" },
        },
        ["hao xiang bu"] = {
            { text = "好像不", comment = "hao xiang bu" },
        },
        ["he bu"] = {
            { text = "何不", comment = "he bu" },
            { text = "喝不", comment = "he bu" },
            { text = "和不", comment = "he bu" },
            { text = "贺部", comment = "he bu" },
            { text = "核补", comment = "he bu" },
        },
        ["he nai"] = {
            { text = "喝奶", comment = "he nai" },
            { text = "和耐", comment = "he nai" },
        },
        ["he nan"] = {
            { text = "河南", comment = "he nan" },
            { text = "贺楠", comment = "he nan" },
            { text = "何楠", comment = "he nan" },
            { text = "何南", comment = "he nan" },
            { text = "鹤南", comment = "he nan" },
            { text = "赫男", comment = "he nan" },
        },
        ["he nei"] = {
            { text = "河内", comment = "he nei" },
            { text = "盒内", comment = "he nei" },
        },
        ["he nin"] = {
            { text = "和您", comment = "he nin" },
        },
        ["he niu"] = {
            { text = "和牛", comment = "he niu" },
        },
        ["he nuan"] = {
            { text = "和暖", comment = "he nuan" },
        },
        ["he nuo"] = {
            { text = "和诺", comment = "he nuo" },
            { text = "荷诺", comment = "he nuo" },
        },
        ["he ou"] = {
            { text = "荷藕", comment = "he ou" },
        },
        ["he tai"] = {
            { text = "和泰", comment = "he tai" },
            { text = "合泰", comment = "he tai" },
            { text = "荷台", comment = "he tai" },
            { text = "禾泰", comment = "he tai" },
            { text = "何太", comment = "he tai" },
        },
        ["he tan"] = {
            { text = "何谈", comment = "he tan" },
            { text = "河滩", comment = "he tan" },
            { text = "和谈", comment = "he tan" },
        },
        ["he tao"] = {
            { text = "核桃", comment = "he tao" },
            { text = "何涛", comment = "he tao" },
            { text = "河套", comment = "he tao" },
            { text = "贺涛", comment = "he tao" },
            { text = "何韬", comment = "he tao" },
            { text = "何滔", comment = "he tao" },
        },
        ["he te"] = {
            { text = "和特", comment = "he te" },
            { text = "赫特", comment = "he te" },
        },
        ["he tie"] = {
            { text = "盒贴", comment = "he tie" },
        },
        ["he tou"] = {
            { text = "河头", comment = "he tou" },
            { text = "合投", comment = "he tou" },
            { text = "合头", comment = "he tou" },
            { text = "和头", comment = "he tou" },
        },
        ["he tou zhen"] = {
            { text = "河头镇", comment = "he tou zhen" },
        },
        ["he tuan"] = {
            { text = "合团", comment = "he tuan" },
            { text = "核团", comment = "he tuan" },
        },
        ["he ya"] = {
            { text = "喝呀", comment = "he ya" },
            { text = "和雅", comment = "he ya" },
            { text = "何亚", comment = "he ya" },
            { text = "何娅", comment = "he ya" },
            { text = "何雅", comment = "he ya" },
            { text = "河崖", comment = "he ya" },
            { text = "和亚", comment = "he ya" },
            { text = "禾雅", comment = "he ya" },
        },
        ["he yan"] = {
            { text = "核验", comment = "he yan" },
            { text = "何艳", comment = "he yan" },
            { text = "何燕", comment = "he yan" },
            { text = "合眼", comment = "he yan" },
            { text = "河沿", comment = "he yan" },
            { text = "贺燕", comment = "he yan" },
            { text = "何岩", comment = "he yan" },
            { text = "何妍", comment = "he yan" },
            { text = "贺艳", comment = "he yan" },
            { text = "何彦", comment = "he yan" },
            { text = "贺岩", comment = "he yan" },
            { text = "赫妍", comment = "he yan" },
            { text = "何晏", comment = "he yan" },
            { text = "合演", comment = "he yan" },
            { text = "何言", comment = "he yan" },
            { text = "何雁", comment = "he yan" },
            { text = "和盐", comment = "he yan" },
            { text = "贺言", comment = "he yan" },
            { text = "贺妍", comment = "he yan" },
        },
        ["he yan li"] = {
            { text = "何艳丽", comment = "he yan li" },
        },
        ["he yao"] = {
            { text = "喝药", comment = "he yao" },
            { text = "何瑶", comment = "he yao" },
            { text = "何耀", comment = "he yao" },
            { text = "何尧", comment = "he yao" },
        },
        ["he ye"] = {
            { text = "荷叶", comment = "he ye" },
            { text = "合页", comment = "he ye" },
            { text = "何叶", comment = "he ye" },
            { text = "合叶", comment = "he ye" },
            { text = "和也", comment = "he ye" },
            { text = "和业", comment = "he ye" },
            { text = "禾野", comment = "he ye" },
            { text = "和叶", comment = "he ye" },
            { text = "何烨", comment = "he ye" },
            { text = "何野", comment = "he ye" },
            { text = "河野", comment = "he ye" },
            { text = "河冶", comment = "he ye" },
            { text = "何晔", comment = "he ye" },
        },
        ["he yin"] = {
            { text = "和音", comment = "he yin" },
            { text = "合音", comment = "he yin" },
            { text = "何银", comment = "he yin" },
            { text = "河阴", comment = "he yin" },
            { text = "合印", comment = "he yin" },
        },
        ["he you"] = {
            { text = "何有", comment = "he you" },
            { text = "喝油", comment = "he you" },
            { text = "和有", comment = "he you" },
            { text = "何友", comment = "he you" },
        },
        ["he yun"] = {
            { text = "喝晕", comment = "he yun" },
            { text = "何云", comment = "he yun" },
            { text = "贺云", comment = "he yun" },
            { text = "荷韵", comment = "he yun" },
            { text = "和韵", comment = "he yun" },
            { text = "和运", comment = "he yun" },
            { text = "何芸", comment = "he yun" },
            { text = "禾云", comment = "he yun" },
            { text = "河运", comment = "he yun" },
            { text = "贺芸", comment = "he yun" },
            { text = "合运", comment = "he yun" },
        },
        ["hei a"] = {
            { text = "黑啊", comment = "hei a" },
        },
        ["hei an"] = {
            { text = "黑暗", comment = "hei an" },
        },
        ["hei an li"] = {
            { text = "黑暗里", comment = "hei an li" },
        },
        ["hei ao"] = {
            { text = "黑奥", comment = "hei ao" },
        },
        ["hei bu"] = {
            { text = "黑布", comment = "hei bu" },
        },
        ["hei e"] = {
            { text = "黑恶", comment = "hei e" },
        },
        ["hei nv"] = {
            { text = "黑女", comment = "hei nv" },
        },
        ["hei yu"] = {
            { text = "黑鱼", comment = "hei yu" },
            { text = "黑羽", comment = "hei yu" },
            { text = "黑玉", comment = "hei yu" },
            { text = "黑域", comment = "hei yu" },
            { text = "黑雨", comment = "hei yu" },
            { text = "黑狱", comment = "hei yu" },
        },
        ["hen ai"] = {
            { text = "很爱", comment = "hen ai" },
            { text = "很矮", comment = "hen ai" },
        },
        ["hen an"] = {
            { text = "很暗", comment = "hen an" },
        },
        ["hen bu"] = {
            { text = "很不", comment = "hen bu" },
        },
        ["hen di"] = {
            { text = "很低", comment = "hen di" },
        },
        ["hen ou"] = {
            { text = "很欧", comment = "hen ou" },
        },
        ["hen wo"] = {
            { text = "恨我", comment = "hen wo" },
        },
        ["hen xu"] = {
            { text = "很虚", comment = "hen xu" },
        },
        ["hen yu"] = {
            { text = "恨与", comment = "hen yu" },
            { text = "恨与", comment = "hen yu" },
        },
        ["heng ai"] = {
            { text = "恒爱", comment = "heng ai" },
        },
        ["heng an"] = {
            { text = "恒安", comment = "heng an" },
            { text = "衡安", comment = "heng an" },
        },
        ["heng ao"] = {
            { text = "恒奥", comment = "heng ao" },
        },
        ["heng bu"] = {
            { text = "横埠", comment = "heng bu" },
        },
        ["heng bu zhen"] = {
            { text = "横埠镇", comment = "heng bu zhen" },
        },
        ["heng e"] = {
            { text = "横额", comment = "heng e" },
            { text = "姮娥", comment = "heng e" },
        },
        ["heng xu"] = {
            { text = "恒旭", comment = "heng xu" },
        },
        ["heng ye"] = {
            { text = "恒业", comment = "heng ye" },
        },
        ["hong bu"] = {
            { text = "红布", comment = "hong bu" },
        },
        ["hong ou"] = {
            { text = "红藕", comment = "hong ou" },
        },
        ["hu ao"] = {
            { text = "胡奥", comment = "hu ao" },
        },
        ["hu ba"] = {
            { text = "胡巴", comment = "hu ba" },
            { text = "虎爸", comment = "hu ba" },
        },
        ["hu bai"] = {
            { text = "狐白", comment = "hu bai" },
        },
        ["hu ban"] = {
            { text = "护板", comment = "hu ban" },
            { text = "虎斑", comment = "hu ban" },
            { text = "弧板", comment = "hu ban" },
        },
        ["hu ban shi"] = {
            { text = "护办室", comment = "hu ban shi" },
        },
        ["hu bao"] = {
            { text = "虎豹", comment = "hu bao" },
            { text = "互保", comment = "hu bao" },
            { text = "互爆", comment = "hu bao" },
            { text = "胡宝", comment = "hu bao" },
            { text = "虎宝", comment = "hu bao" },
            { text = "护宝", comment = "hu bao" },
            { text = "沪宝", comment = "hu bao" },
        },
        ["hu bei"] = {
            { text = "湖北", comment = "hu bei" },
            { text = "湖贝", comment = "hu bei" },
            { text = "沪北", comment = "hu bei" },
            { text = "胡北", comment = "hu bei" },
            { text = "胡蓓", comment = "hu bei" },
            { text = "胡贝", comment = "hu bei" },
            { text = "护背", comment = "hu bei" },
        },
        ["hu ben"] = {
            { text = "虎贲", comment = "hu ben" },
            { text = "护本", comment = "hu ben" },
        },
        ["hu bin"] = {
            { text = "湖滨", comment = "hu bin" },
            { text = "胡斌", comment = "hu bin" },
            { text = "胡彬", comment = "hu bin" },
            { text = "胡滨", comment = "hu bin" },
            { text = "胡宾", comment = "hu bin" },
        },
        ["hu bu"] = {
            { text = "互补", comment = "hu bu" },
            { text = "互不", comment = "hu bu" },
            { text = "户部", comment = "hu bu" },
            { text = "胡部", comment = "hu bu" },
            { text = "虎步", comment = "hu bu" },
            { text = "糊布", comment = "hu bu" },
        },
        ["hu fo"] = {
            { text = "胡佛", comment = "hu fo" },
        },
        ["hu na"] = {
            { text = "胡娜", comment = "hu na" },
        },
        ["hu nan"] = {
            { text = "湖南", comment = "hu nan" },
            { text = "胡楠", comment = "hu nan" },
            { text = "沪南", comment = "hu nan" },
            { text = "胡南", comment = "hu nan" },
        },
        ["hu nan de"] = {
            { text = "湖南的", comment = "hu nan de" },
        },
        ["hu nei"] = {
            { text = "户内", comment = "hu nei" },
            { text = "湖内", comment = "hu nei" },
        },
        ["hu nie"] = {
            { text = "沪镍", comment = "hu nie" },
        },
        ["hu niu"] = {
            { text = "虎妞", comment = "hu niu" },
            { text = "虎牛", comment = "hu niu" },
        },
        ["hu nuan"] = {
            { text = "互暖", comment = "hu nuan" },
        },
        ["hu ou"] = {
            { text = "互殴", comment = "hu ou" },
        },
        ["hu ya"] = {
            { text = "虎牙", comment = "hu ya" },
            { text = "胡亚", comment = "hu ya" },
            { text = "胡雅", comment = "hu ya" },
            { text = "胡娅", comment = "hu ya" },
        },
        ["hu yan"] = {
            { text = "护眼", comment = "hu yan" },
            { text = "胡艳", comment = "hu yan" },
            { text = "胡燕", comment = "hu yan" },
            { text = "呼延", comment = "hu yan" },
            { text = "虎眼", comment = "hu yan" },
            { text = "胡言", comment = "hu yan" },
            { text = "狐言", comment = "hu yan" },
            { text = "胡岩", comment = "hu yan" },
            { text = "胡彦", comment = "hu yan" },
            { text = "胡妍", comment = "hu yan" },
            { text = "胡炎", comment = "hu yan" },
            { text = "互宴", comment = "hu yan" },
        },
        ["hu yan li"] = {
            { text = "胡艳丽", comment = "hu yan li" },
        },
        ["hu yang"] = {
            { text = "胡杨", comment = "hu yang" },
            { text = "胡洋", comment = "hu yang" },
            { text = "胡阳", comment = "hu yang" },
            { text = "护养", comment = "hu yang" },
            { text = "湖羊", comment = "hu yang" },
            { text = "湖阳", comment = "hu yang" },
            { text = "湖洋", comment = "hu yang" },
            { text = "胡扬", comment = "hu yang" },
        },
        ["hu ye"] = {
            { text = "虎爷", comment = "hu ye" },
            { text = "胡叶", comment = "hu ye" },
            { text = "胡烨", comment = "hu ye" },
            { text = "胡野", comment = "hu ye" },
        },
        ["hu yin"] = {
            { text = "护龈", comment = "hu yin" },
            { text = "沪银", comment = "hu yin" },
            { text = "胡银", comment = "hu yin" },
            { text = "胡寅", comment = "hu yin" },
        },
        ["hu you"] = {
            { text = "忽悠", comment = "hu you" },
            { text = "护佑", comment = "hu you" },
            { text = "胡柚", comment = "hu you" },
            { text = "胡油", comment = "hu you" },
            { text = "胡友", comment = "hu you" },
            { text = "狐友", comment = "hu you" },
            { text = "壶友", comment = "hu you" },
            { text = "户牖", comment = "hu you" },
        },
        ["hu yuan"] = {
            { text = "护院", comment = "hu yuan" },
            { text = "胡媛", comment = "hu yuan" },
            { text = "胡元", comment = "hu yuan" },
            { text = "胡院", comment = "hu yuan" },
            { text = "胡源", comment = "hu yuan" },
            { text = "胡远", comment = "hu yuan" },
            { text = "胡园", comment = "hu yuan" },
            { text = "虎园", comment = "hu yuan" },
            { text = "湖源", comment = "hu yuan" },
            { text = "护院", comment = "hu yuan" },
            { text = "胡媛", comment = "hu yuan" },
            { text = "胡元", comment = "hu yuan" },
            { text = "胡院", comment = "hu yuan" },
            { text = "胡源", comment = "hu yuan" },
            { text = "胡远", comment = "hu yuan" },
            { text = "胡园", comment = "hu yuan" },
            { text = "虎园", comment = "hu yuan" },
            { text = "湖源", comment = "hu yuan" },
        },
        ["hu yue"] = {
            { text = "胡月", comment = "hu yue" },
            { text = "胡悦", comment = "hu yue" },
            { text = "虎跃", comment = "hu yue" },
            { text = "胡越", comment = "hu yue" },
            { text = "胡玥", comment = "hu yue" },
            { text = "胡跃", comment = "hu yue" },
            { text = "狐月", comment = "hu yue" },
            { text = "胡岳", comment = "hu yue" },
            { text = "互阅", comment = "hu yue" },
        },
        ["hua an"] = {
            { text = "华安", comment = "hua an" },
        },
        ["hua an bao"] = {
            { text = "华安保", comment = "hua an bao" },
        },
        ["hua an li"] = {
            { text = "华安里", comment = "hua an li" },
        },
        ["hua an tang"] = {
            { text = "花安堂", comment = "hua an tang" },
        },
        ["hua ang"] = {
            { text = "华昂", comment = "hua ang" },
        },
        ["hua ao"] = {
            { text = "华奥", comment = "hua ao" },
            { text = "华澳", comment = "hua ao" },
            { text = "华傲", comment = "hua ao" },
        },
        ["hua ba"] = {
            { text = "话吧", comment = "hua ba" },
            { text = "画吧", comment = "hua ba" },
            { text = "花吧", comment = "hua ba" },
            { text = "花坝", comment = "hua ba" },
        },
        ["hua bai"] = {
            { text = "花白", comment = "hua bai" },
            { text = "华百", comment = "hua bai" },
            { text = "华柏", comment = "hua bai" },
            { text = "化白", comment = "hua bai" },
            { text = "话白", comment = "hua bai" },
        },
        ["hua ban"] = {
            { text = "花瓣", comment = "hua ban" },
            { text = "滑板", comment = "hua ban" },
            { text = "画板", comment = "hua ban" },
            { text = "花板", comment = "hua ban" },
            { text = "花斑", comment = "hua ban" },
            { text = "花伴", comment = "hua ban" },
        },
        ["hua bang"] = {
            { text = "华邦", comment = "hua bang" },
            { text = "花榜", comment = "hua bang" },
            { text = "花棒", comment = "hua bang" },
        },
        ["hua bao"] = {
            { text = "画报", comment = "hua bao" },
            { text = "华宝", comment = "hua bao" },
            { text = "花苞", comment = "hua bao" },
            { text = "花豹", comment = "hua bao" },
            { text = "华保", comment = "hua bao" },
            { text = "花宝", comment = "hua bao" },
            { text = "华堡", comment = "hua bao" },
        },
        ["hua bei"] = {
            { text = "花呗", comment = "hua bei" },
            { text = "华北", comment = "hua bei" },
            { text = "华贝", comment = "hua bei" },
            { text = "花被", comment = "hua bei" },
            { text = "华杯", comment = "hua bei" },
        },
        ["hua ben"] = {
            { text = "话本", comment = "hua ben" },
            { text = "画本", comment = "hua ben" },
            { text = "华奔", comment = "hua ben" },
        },
        ["hua bie"] = {
            { text = "话别", comment = "hua bie" },
        },
        ["hua bo"] = {
            { text = "划拨", comment = "hua bo" },
            { text = "华博", comment = "hua bo" },
            { text = "花钵", comment = "hua bo" },
            { text = "化玻", comment = "hua bo" },
            { text = "华波", comment = "hua bo" },
            { text = "花博", comment = "hua bo" },
        },
        ["hua bo di"] = {
            { text = "划拨地", comment = "hua bo di" },
        },
        ["hua bu"] = {
            { text = "画布", comment = "hua bu" },
            { text = "话补", comment = "hua bu" },
            { text = "滑步", comment = "hua bu" },
            { text = "花布", comment = "hua bu" },
            { text = "华埠", comment = "hua bu" },
            { text = "话不", comment = "hua bu" },
        },
        ["hua bu cheng"] = {
            { text = "画不成", comment = "hua bu cheng" },
        },
        ["hua bu chu"] = {
            { text = "画不出", comment = "hua bu chu" },
        },
        ["hua bu duo"] = {
            { text = "话不多", comment = "hua bu duo" },
        },
        ["hua bu hua"] = {
            { text = "花不花", comment = "hua bu hua" },
            { text = "画不画", comment = "hua bu hua" },
            { text = "滑不滑", comment = "hua bu hua" },
        },
        ["hua bu hua suan"] = {
            { text = "划不划算", comment = "hua bu hua suan" },
        },
        ["hua bu le"] = {
            { text = "花不了", comment = "hua bu le" },
        },
        ["hua bu liao"] = {
            { text = "花不了", comment = "hua bu liao" },
        },
        ["hua bu qi"] = {
            { text = "花不弃", comment = "hua bu qi" },
        },
        ["hua bu wan"] = {
            { text = "花不完", comment = "hua bu wan" },
        },
        ["hua bu yu"] = {
            { text = "花不语", comment = "hua bu yu" },
            { text = "花不语", comment = "hua bu yu" },
        },
        ["hua bu zhao"] = {
            { text = "划不着", comment = "hua bu zhao" },
        },
        ["hua bu zhe"] = {
            { text = "划不着", comment = "hua bu zhe" },
        },
        ["hua bu zhen"] = {
            { text = "华埠镇", comment = "hua bu zhen" },
        },
        ["hua da"] = {
            { text = "华大", comment = "hua da" },
            { text = "华达", comment = "hua da" },
            { text = "化大", comment = "hua da" },
        },
        ["hua dai"] = {
            { text = "画袋", comment = "hua dai" },
            { text = "花带", comment = "hua dai" },
            { text = "花袋", comment = "hua dai" },
            { text = "滑带", comment = "hua dai" },
        },
        ["hua dang"] = {
            { text = "滑档", comment = "hua dang" },
        },
        ["hua die"] = {
            { text = "化蝶", comment = "hua die" },
            { text = "花蝶", comment = "hua die" },
        },
        ["hua dou"] = {
            { text = "花豆", comment = "hua dou" },
            { text = "花都", comment = "hua dou" },
            { text = "话都", comment = "hua dou" },
        },
        ["hua duo"] = {
            { text = "话多", comment = "hua duo" },
            { text = "花朵", comment = "hua duo" },
            { text = "华多", comment = "hua duo" },
        },
        ["hua e"] = {
            { text = "花萼", comment = "hua e" },
        },
        ["hua en"] = {
            { text = "华恩", comment = "hua en" },
        },
        ["hua huai"] = {
            { text = "划坏", comment = "hua huai" },
        },
        ["hua na"] = {
            { text = "华纳", comment = "hua na" },
            { text = "华娜", comment = "hua na" },
        },
        ["hua nai"] = {
            { text = "花奶", comment = "hua nai" },
            { text = "华耐", comment = "hua nai" },
        },
        ["hua nan"] = {
            { text = "华南", comment = "hua nan" },
            { text = "桦南", comment = "hua nan" },
            { text = "华楠", comment = "hua nan" },
        },
        ["hua nei"] = {
            { text = "画内", comment = "hua nei" },
        },
        ["hua nie"] = {
            { text = "化镍", comment = "hua nie" },
        },
        ["hua niu"] = {
            { text = "花牛", comment = "hua niu" },
            { text = "华牛", comment = "hua niu" },
        },
        ["hua nuan"] = {
            { text = "华暖", comment = "hua nuan" },
            { text = "花暖", comment = "hua nuan" },
        },
        ["hua nuo"] = {
            { text = "华诺", comment = "hua nuo" },
        },
        ["hua ou"] = {
            { text = "华欧", comment = "hua ou" },
        },
        ["hua ri"] = {
            { text = "华日", comment = "hua ri" },
        },
        ["hua ta"] = {
            { text = "滑塌", comment = "hua ta" },
        },
        ["hua tai"] = {
            { text = "华泰", comment = "hua tai" },
            { text = "花台", comment = "hua tai" },
            { text = "滑台", comment = "hua tai" },
            { text = "华太", comment = "hua tai" },
            { text = "滑胎", comment = "hua tai" },
            { text = "华台", comment = "hua tai" },
        },
        ["hua tan"] = {
            { text = "花坛", comment = "hua tan" },
            { text = "化痰", comment = "hua tan" },
            { text = "化碳", comment = "hua tan" },
            { text = "花滩", comment = "hua tan" },
            { text = "化探", comment = "hua tan" },
            { text = "画坛", comment = "hua tan" },
            { text = "花谈", comment = "hua tan" },
        },
        ["hua te"] = {
            { text = "华特", comment = "hua te" },
        },
        ["hua tie"] = {
            { text = "华铁", comment = "hua tie" },
            { text = "画帖", comment = "hua tie" },
        },
        ["hua tou"] = {
            { text = "花头", comment = "hua tou" },
            { text = "滑头", comment = "hua tou" },
            { text = "话头", comment = "hua tou" },
        },
        ["hua tuan"] = {
            { text = "花团", comment = "hua tuan" },
        },
        ["hua tuo"] = {
            { text = "华佗", comment = "hua tuo" },
            { text = "滑脱", comment = "hua tuo" },
            { text = "华拓", comment = "hua tuo" },
            { text = "花托", comment = "hua tuo" },
        },
        ["hua wai"] = {
            { text = "化外", comment = "hua wai" },
            { text = "画外", comment = "hua wai" },
            { text = "华外", comment = "hua wai" },
        },
        ["hua wei"] = {
            { text = "华为", comment = "hua wei" },
            { text = "化为", comment = "hua wei" },
            { text = "华威", comment = "hua wei" },
            { text = "华伟", comment = "hua wei" },
            { text = "划为", comment = "hua wei" },
            { text = "华维", comment = "hua wei" },
            { text = "华微", comment = "hua wei" },
            { text = "华卫", comment = "hua wei" },
            { text = "花位", comment = "hua wei" },
            { text = "花味", comment = "hua wei" },
            { text = "华炜", comment = "hua wei" },
            { text = "华纬", comment = "hua wei" },
            { text = "华潍", comment = "hua wei" },
            { text = "华玮", comment = "hua wei" },
            { text = "画位", comment = "hua wei" },
            { text = "骅威", comment = "hua wei" },
        },
        ["hua wo"] = {
            { text = "花我", comment = "hua wo" },
            { text = "话我", comment = "hua wo" },
            { text = "华沃", comment = "hua wo" },
        },
        ["hua wo zhi"] = {
            { text = "话我知", comment = "hua wo zhi" },
        },
        ["hua xu"] = {
            { text = "花絮", comment = "hua xu" },
            { text = "华旭", comment = "hua xu" },
            { text = "花须", comment = "hua xu" },
            { text = "花序", comment = "hua xu" },
            { text = "华胥", comment = "hua xu" },
        },
        ["hua xu tu"] = {
            { text = "花絮图", comment = "hua xu tu" },
        },
        ["hua xu yin"] = {
            { text = "华胥引", comment = "hua xu yin" },
        },
        ["hua xu zhen"] = {
            { text = "华胥镇", comment = "hua xu zhen" },
        },
        ["hua xue"] = {
            { text = "化学", comment = "hua xue" },
            { text = "滑雪", comment = "hua xue" },
            { text = "化雪", comment = "hua xue" },
            { text = "华雪", comment = "hua xue" },
            { text = "滑靴", comment = "hua xue" },
        },
        ["hua ya"] = {
            { text = "画押", comment = "hua ya" },
            { text = "华亚", comment = "hua ya" },
            { text = "滑牙", comment = "hua ya" },
            { text = "华雅", comment = "hua ya" },
            { text = "花芽", comment = "hua ya" },
            { text = "花押", comment = "hua ya" },
        },
        ["hua yan"] = {
            { text = "化验", comment = "hua yan" },
            { text = "花眼", comment = "hua yan" },
            { text = "华研", comment = "hua yan" },
            { text = "华燕", comment = "hua yan" },
            { text = "华岩", comment = "hua yan" },
            { text = "华严", comment = "hua yan" },
            { text = "花颜", comment = "hua yan" },
            { text = "华艳", comment = "hua yan" },
            { text = "花言", comment = "hua yan" },
            { text = "花宴", comment = "hua yan" },
            { text = "花艳", comment = "hua yan" },
            { text = "华衍", comment = "hua yan" },
            { text = "划眼", comment = "hua yan" },
            { text = "华雁", comment = "hua yan" },
            { text = "花妍", comment = "hua yan" },
            { text = "华宴", comment = "hua yan" },
        },
        ["hua yan lu"] = {
            { text = "华岩路", comment = "hua yan lu" },
            { text = "华严路", comment = "hua yan lu" },
        },
        ["hua yan shi"] = {
            { text = "化验室", comment = "hua yan shi" },
        },
        ["hua yan xian"] = {
            { text = "画眼线", comment = "hua yan xian" },
        },
        ["hua yang"] = {
            { text = "花样", comment = "hua yang" },
            { text = "华阳", comment = "hua yang" },
            { text = "华洋", comment = "hua yang" },
            { text = "花漾", comment = "hua yang" },
            { text = "华扬", comment = "hua yang" },
            { text = "华杨", comment = "hua yang" },
            { text = "花阳", comment = "hua yang" },
        },
        ["hua yao"] = {
            { text = "花妖", comment = "hua yao" },
            { text = "华耀", comment = "hua yao" },
            { text = "化药", comment = "hua yao" },
            { text = "华药", comment = "hua yao" },
            { text = "话要", comment = "hua yao" },
            { text = "花药", comment = "hua yao" },
            { text = "花瑶", comment = "hua yao" },
        },
        ["hua ye"] = {
            { text = "华业", comment = "hua ye" },
            { text = "花叶", comment = "hua ye" },
            { text = "华冶", comment = "hua ye" },
            { text = "华烨", comment = "hua ye" },
            { text = "话也", comment = "hua ye" },
            { text = "华野", comment = "hua ye" },
            { text = "花爷", comment = "hua ye" },
            { text = "华叶", comment = "hua ye" },
            { text = "画页", comment = "hua ye" },
            { text = "华晔", comment = "hua ye" },
            { text = "花野", comment = "hua ye" },
        },
        ["hua yin"] = {
            { text = "话音", comment = "hua yin" },
            { text = "华银", comment = "hua yin" },
            { text = "华阴", comment = "hua yin" },
            { text = "花印", comment = "hua yin" },
            { text = "滑音", comment = "hua yin" },
            { text = "花音", comment = "hua yin" },
            { text = "华音", comment = "hua yin" },
            { text = "华印", comment = "hua yin" },
            { text = "华寅", comment = "hua yin" },
        },
        ["hua you"] = {
            { text = "华油", comment = "hua you" },
            { text = "华友", comment = "hua you" },
            { text = "滑油", comment = "hua you" },
            { text = "华优", comment = "hua you" },
            { text = "华佑", comment = "hua you" },
            { text = "花友", comment = "hua you" },
            { text = "画友", comment = "hua you" },
            { text = "华有", comment = "hua you" },
            { text = "花油", comment = "hua you" },
            { text = "花游", comment = "hua you" },
            { text = "华邮", comment = "hua you" },
        },
        ["hua yuan"] = {
            { text = "花园", comment = "hua yuan" },
            { text = "花苑", comment = "hua yuan" },
            { text = "华源", comment = "hua yuan" },
            { text = "华远", comment = "hua yuan" },
            { text = "华苑", comment = "hua yuan" },
            { text = "华元", comment = "hua yuan" },
            { text = "化缘", comment = "hua yuan" },
            { text = "画圆", comment = "hua yuan" },
            { text = "华园", comment = "hua yuan" },
            { text = "画院", comment = "hua yuan" },
            { text = "花垣", comment = "hua yuan" },
            { text = "化院", comment = "hua yuan" },
            { text = "花源", comment = "hua yuan" },
            { text = "华原", comment = "hua yuan" },
            { text = "化原", comment = "hua yuan" },
            { text = "画苑", comment = "hua yuan" },
        },
        ["hua yun"] = {
            { text = "华云", comment = "hua yun" },
            { text = "华运", comment = "hua yun" },
            { text = "华韵", comment = "hua yun" },
            { text = "花韵", comment = "hua yun" },
            { text = "花云", comment = "hua yun" },
            { text = "华芸", comment = "hua yun" },
        },
        ["huai"] = {
            { text = "坏", comment = "huai" },
            { text = "怀", comment = "huai" },
            { text = "淮", comment = "huai" },
            { text = "槐", comment = "huai" },
            { text = "踝", comment = "huai" },
            { text = "徊", comment = "huai" },
            { text = "耲", comment = "huai" },
        },
        ["huai an"] = {
            { text = "淮安", comment = "huai an" },
            { text = "怀安", comment = "huai an" },
            { text = "槐安", comment = "huai an" },
        },
        ["huai an lu"] = {
            { text = "槐安路", comment = "huai an lu" },
        },
        ["huai an shi"] = {
            { text = "淮安市", comment = "huai an shi" },
        },
        ["huai an xian"] = {
            { text = "怀安县", comment = "huai an xian" },
        },
        ["huai ba"] = {
            { text = "坏吧", comment = "huai ba" },
            { text = "耲耙", comment = "huai ba" },
        },
        ["huai bao"] = {
            { text = "怀抱", comment = "huai bao" },
            { text = "怀宝", comment = "huai bao" },
            { text = "坏包", comment = "huai bao" },
            { text = "坏宝", comment = "huai bao" },
        },
        ["huai bei"] = {
            { text = "淮北", comment = "huai bei" },
            { text = "怀北", comment = "huai bei" },
            { text = "槐北", comment = "huai bei" },
        },
        ["huai biao"] = {
            { text = "怀表", comment = "huai biao" },
        },
        ["huai bu"] = {
            { text = "踝部", comment = "huai bu" },
        },
        ["huai cai"] = {
            { text = "怀才", comment = "huai cai" },
            { text = "坏菜", comment = "huai cai" },
        },
        ["huai che"] = {
            { text = "坏车", comment = "huai che" },
        },
        ["huai cheng"] = {
            { text = "怀城", comment = "huai cheng" },
            { text = "淮城", comment = "huai cheng" },
        },
        ["huai chu"] = {
            { text = "坏处", comment = "huai chu" },
        },
        ["huai chuan"] = {
            { text = "淮川", comment = "huai chuan" },
        },
        ["huai chun"] = {
            { text = "怀春", comment = "huai chun" },
        },
        ["huai dan"] = {
            { text = "坏蛋", comment = "huai dan" },
            { text = "坏单", comment = "huai dan" },
        },
        ["huai dang"] = {
            { text = "怀挡", comment = "huai dang" },
        },
        ["huai dao"] = {
            { text = "坏道", comment = "huai dao" },
        },
        ["huai de"] = {
            { text = "坏的", comment = "huai de" },
            { text = "怀德", comment = "huai de" },
            { text = "怀的", comment = "huai de" },
        },
        ["huai di"] = {
            { text = "槐底", comment = "huai di" },
        },
        ["huai dian"] = {
            { text = "坏点", comment = "huai dian" },
            { text = "槐店", comment = "huai dian" },
        },
        ["huai dong"] = {
            { text = "槐东", comment = "huai dong" },
            { text = "怀东", comment = "huai dong" },
            { text = "淮东", comment = "huai dong" },
        },
        ["huai en"] = {
            { text = "怀恩", comment = "huai en" },
        },
        ["huai er"] = {
            { text = "槐耳", comment = "huai er" },
        },
        ["huai fang"] = {
            { text = "槐房", comment = "huai fang" },
        },
        ["huai fei"] = {
            { text = "怀飞", comment = "huai fei" },
        },
        ["huai feng"] = {
            { text = "怀峰", comment = "huai feng" },
        },
        ["huai fu"] = {
            { text = "怀府", comment = "huai fu" },
        },
        ["huai gang"] = {
            { text = "淮钢", comment = "huai gang" },
        },
        ["huai gao"] = {
            { text = "淮高", comment = "huai gao" },
        },
        ["huai ge"] = {
            { text = "怀个", comment = "huai ge" },
            { text = "怀哥", comment = "huai ge" },
            { text = "坏哥", comment = "huai ge" },
            { text = "淮哥", comment = "huai ge" },
        },
        ["huai gong"] = {
            { text = "淮工", comment = "huai gong" },
        },
        ["huai gu"] = {
            { text = "怀古", comment = "huai gu" },
            { text = "踝骨", comment = "huai gu" },
        },
        ["huai guang"] = {
            { text = "怀光", comment = "huai guang" },
        },
        ["huai gui"] = {
            { text = "怀归", comment = "huai gui" },
        },
        ["huai guo"] = {
            { text = "坏果", comment = "huai guo" },
            { text = "坏过", comment = "huai guo" },
        },
        ["huai hai"] = {
            { text = "淮海", comment = "huai hai" },
        },
        ["huai he"] = {
            { text = "淮河", comment = "huai he" },
        },
        ["huai hu"] = {
            { text = "槐琥", comment = "huai hu" },
        },
        ["huai hua"] = {
            { text = "坏话", comment = "huai hua" },
            { text = "怀化", comment = "huai hua" },
            { text = "槐花", comment = "huai hua" },
        },
        ["huai huai"] = {
            { text = "坏坏", comment = "huai huai" },
            { text = "怀怀", comment = "huai huai" },
        },
        ["huai huo"] = {
            { text = "坏货", comment = "huai huo" },
        },
        ["huai ji"] = {
            { text = "怀集", comment = "huai ji" },
            { text = "坏机", comment = "huai ji" },
            { text = "怀吉", comment = "huai ji" },
        },
        ["huai jian"] = {
            { text = "坏件", comment = "huai jian" },
        },
        ["huai jiang"] = {
            { text = "怀姜", comment = "huai jiang" },
        },
        ["huai jiao"] = {
            { text = "槐角", comment = "huai jiao" },
        },
        ["huai jie"] = {
            { text = "怀杰", comment = "huai jie" },
        },
        ["huai jin"] = {
            { text = "怀瑾", comment = "huai jin" },
        },
        ["huai jiu"] = {
            { text = "怀旧", comment = "huai jiu" },
        },
        ["huai ju"] = {
            { text = "坏疽", comment = "huai ju" },
            { text = "淮剧", comment = "huai ju" },
        },
        ["huai jun"] = {
            { text = "怀军", comment = "huai jun" },
        },
        ["huai ka"] = {
            { text = "坏卡", comment = "huai ka" },
        },
        ["huai kan"] = {
            { text = "槐坎", comment = "huai kan" },
        },
        ["huai kou"] = {
            { text = "淮口", comment = "huai kou" },
        },
        ["huai kuan"] = {
            { text = "坏款", comment = "huai kuan" },
        },
        ["huai kuang"] = {
            { text = "淮矿", comment = "huai kuang" },
        },
        ["huai lai"] = {
            { text = "怀来", comment = "huai lai" },
        },
        ["huai le"] = {
            { text = "坏了", comment = "huai le" },
            { text = "怀了", comment = "huai le" },
        },
        ["huai li"] = {
            { text = "怀里", comment = "huai li" },
        },
        ["huai lian"] = {
            { text = "怀恋", comment = "huai lian" },
        },
        ["huai liang"] = {
            { text = "怀亮", comment = "huai liang" },
        },
        ["huai liao"] = {
            { text = "坏料", comment = "huai liao" },
        },
        ["huai long"] = {
            { text = "怀龙", comment = "huai long" },
        },
        ["huai lu"] = {
            { text = "怀炉", comment = "huai lu" },
        },
        ["huai ma"] = {
            { text = "坏吗", comment = "huai ma" },
        },
        ["huai mian"] = {
            { text = "怀缅", comment = "huai mian" },
        },
        ["huai mu"] = {
            { text = "槐木", comment = "huai mu" },
        },
        ["huai na"] = {
            { text = "怀那", comment = "huai na" },
        },
        ["huai ni"] = {
            { text = "坏你", comment = "huai ni" },
        },
        ["huai o"] = {
            { text = "坏哦", comment = "huai o" },
        },
        ["huai pan"] = {
            { text = "坏盘", comment = "huai pan" },
        },
        ["huai ping"] = {
            { text = "怀平", comment = "huai ping" },
        },
        ["huai qi"] = {
            { text = "怀起", comment = "huai qi" },
        },
        ["huai qian"] = {
            { text = "怀谦", comment = "huai qian" },
        },
        ["huai qiang"] = {
            { text = "怀强", comment = "huai qiang" },
        },
        ["huai qing"] = {
            { text = "怀庆", comment = "huai qing" },
        },
        ["huai rong"] = {
            { text = "怀荣", comment = "huai rong" },
        },
        ["huai rou"] = {
            { text = "怀柔", comment = "huai rou" },
        },
        ["huai shan"] = {
            { text = "淮山", comment = "huai shan" },
            { text = "怀山", comment = "huai shan" },
        },
        ["huai shang"] = {
            { text = "怀上", comment = "huai shang" },
            { text = "淮上", comment = "huai shang" },
        },
        ["huai sheng"] = {
            { text = "怀生", comment = "huai sheng" },
        },
        ["huai shi"] = {
            { text = "坏事", comment = "huai shi" },
            { text = "淮师", comment = "huai shi" },
        },
        ["huai shi qing"] = {
            { text = "坏事情", comment = "huai shi qing" },
        },
        ["huai shou"] = {
            { text = "坏兽", comment = "huai shou" },
        },
        ["huai shu"] = {
            { text = "槐树", comment = "huai shu" },
            { text = "淮树", comment = "huai shu" },
        },
        ["huai shu ju"] = {
            { text = "坏数据", comment = "huai shu ju" },
        },
        ["huai shui"] = {
            { text = "坏水", comment = "huai shui" },
            { text = "淮水", comment = "huai shui" },
        },
        ["huai shuo"] = {
            { text = "怀朔", comment = "huai shuo" },
        },
        ["huai si"] = {
            { text = "坏死", comment = "huai si" },
            { text = "槐泗", comment = "huai si" },
        },
        ["huai song"] = {
            { text = "坏怂", comment = "huai song" },
        },
        ["huai ta"] = {
            { text = "淮塔", comment = "huai ta" },
        },
        ["huai tai"] = {
            { text = "怀胎", comment = "huai tai" },
        },
        ["huai te"] = {
            { text = "怀特", comment = "huai te" },
            { text = "淮特", comment = "huai te" },
        },
        ["huai wang"] = {
            { text = "怀王", comment = "huai wang" },
        },
        ["huai wei"] = {
            { text = "怀伟", comment = "huai wei" },
            { text = "淮委", comment = "huai wei" },
        },
        ["huai wen"] = {
            { text = "怀文", comment = "huai wen" },
            { text = "淮文", comment = "huai wen" },
        },
        ["huai wen ming"] = {
            { text = "坏文明", comment = "huai wen ming" },
        },
        ["huai xi"] = {
            { text = "淮西", comment = "huai xi" },
        },
        ["huai xia"] = {
            { text = "怀霞", comment = "huai xia" },
        },
        ["huai xian"] = {
            { text = "怀先", comment = "huai xian" },
        },
        ["huai xiang"] = {
            { text = "怀想", comment = "huai xiang" },
            { text = "怀乡", comment = "huai xiang" },
        },
        ["huai xiao"] = {
            { text = "坏笑", comment = "huai xiao" },
        },
        ["huai xiao xi"] = {
            { text = "坏消息", comment = "huai xiao xi" },
        },
        ["huai xie"] = {
            { text = "坏血", comment = "huai xie" },
        },
        ["huai xin"] = {
            { text = "坏心", comment = "huai xin" },
            { text = "槐新", comment = "huai xin" },
        },
        ["huai xing"] = {
            { text = "怀兴", comment = "huai xing" },
        },
        ["huai xu"] = {
            { text = "槐序", comment = "huai xu" },
        },
        ["huai ya"] = {
            { text = "坏牙", comment = "huai ya" },
            { text = "槐芽", comment = "huai ya" },
        },
        ["huai yan"] = {
            { text = "淮盐", comment = "huai yan" },
        },
        ["huai yang"] = {
            { text = "淮阳", comment = "huai yang" },
            { text = "淮扬", comment = "huai yang" },
            { text = "怀阳", comment = "huai yang" },
        },
        ["huai yao"] = {
            { text = "怀药", comment = "huai yao" },
        },
        ["huai yi"] = {
            { text = "怀疑", comment = "huai yi" },
            { text = "怀义", comment = "huai yi" },
            { text = "淮夷", comment = "huai yi" },
        },
        ["huai ying"] = {
            { text = "怀英", comment = "huai ying" },
        },
        ["huai yong"] = {
            { text = "怀勇", comment = "huai yong" },
        },
        ["huai you"] = {
            { text = "怀有", comment = "huai you" },
            { text = "怀友", comment = "huai you" },
        },
        ["huai yu"] = {
            { text = "怀玉", comment = "huai yu" },
            { text = "怀宇", comment = "huai yu" },
        },
        ["huai yuan"] = {
            { text = "怀远", comment = "huai yuan" },
            { text = "淮源", comment = "huai yuan" },
            { text = "槐园", comment = "huai yuan" },
        },
        ["huai yue"] = {
            { text = "怀月", comment = "huai yue" },
        },
        ["huai yun"] = {
            { text = "怀孕", comment = "huai yun" },
        },
        ["huai zai"] = {
            { text = "坏在", comment = "huai zai" },
        },
        ["huai zhang"] = {
            { text = "坏账", comment = "huai zhang" },
        },
        ["huai zhen"] = {
            { text = "淮镇", comment = "huai zhen" },
        },
        ["huai zhi"] = {
            { text = "怀志", comment = "huai zhi" },
            { text = "淮职", comment = "huai zhi" },
        },
        ["huai zhong"] = {
            { text = "怀中", comment = "huai zhong" },
            { text = "坏种", comment = "huai zhong" },
            { text = "淮中", comment = "huai zhong" },
        },
        ["huai zhou"] = {
            { text = "淮州", comment = "huai zhou" },
        },
        ["huai zhu"] = {
            { text = "坏猪", comment = "huai zhu" },
            { text = "淮竹", comment = "huai zhu" },
        },
        ["huai zhuang"] = {
            { text = "怀庄", comment = "huai zhuang" },
        },
        ["huan a"] = {
            { text = "换啊", comment = "huan a" },
        },
        ["huan ai"] = {
            { text = "患癌", comment = "huan ai" },
            { text = "欢爱", comment = "huan ai" },
        },
        ["huan an"] = {
            { text = "环安", comment = "huan an" },
        },
        ["huan bu"] = {
            { text = "换不", comment = "huan bu" },
            { text = "缓步", comment = "huan bu" },
            { text = "换布", comment = "huan bu" },
        },
        ["huan di"] = {
            { text = "换地", comment = "huan di" },
            { text = "换底", comment = "huan di" },
        },
        ["huan ou"] = {
            { text = "环欧", comment = "huan ou" },
        },
        ["huan wo"] = {
            { text = "还我", comment = "huan wo" },
            { text = "换我", comment = "huan wo" },
            { text = "唤我", comment = "huan wo" },
        },
        ["huan xu"] = {
            { text = "环旭", comment = "huan xu" },
        },
        ["huan ye"] = {
            { text = "幻夜", comment = "huan ye" },
            { text = "换页", comment = "huan ye" },
            { text = "换液", comment = "huan ye" },
            { text = "欢爷", comment = "huan ye" },
        },
        ["huan yu"] = {
            { text = "环宇", comment = "huan yu" },
            { text = "寰宇", comment = "huan yu" },
            { text = "欢愉", comment = "huan yu" },
            { text = "幻羽", comment = "huan yu" },
            { text = "鲩鱼", comment = "huan yu" },
            { text = "幻玉", comment = "huan yu" },
            { text = "欢娱", comment = "huan yu" },
            { text = "桓宇", comment = "huan yu" },
        },
        ["huang a"] = {
            { text = "慌啊", comment = "huang a" },
        },
        ["huang ai"] = {
            { text = "黄爱", comment = "huang ai" },
        },
        ["huang an"] = {
            { text = "黄安", comment = "huang an" },
            { text = "磺胺", comment = "huang an" },
        },
        ["huang bu"] = {
            { text = "黄埠", comment = "huang bu" },
            { text = "黄部", comment = "huang bu" },
            { text = "黄布", comment = "huang bu" },
        },
        ["huang e"] = {
            { text = "荒厄", comment = "huang e" },
        },
        ["huang huai"] = {
            { text = "黄淮", comment = "huang huai" },
            { text = "黄槐", comment = "huang huai" },
        },
        ["huang ri"] = {
            { text = "黄日", comment = "huang ri" },
        },
        ["huang wo"] = {
            { text = "幌斡", comment = "huang wo" },
        },
        ["huang xu"] = {
            { text = "黄旭", comment = "huang xu" },
            { text = "黄许", comment = "huang xu" },
        },
        ["huang ye"] = {
            { text = "荒野", comment = "huang ye" },
            { text = "黄页", comment = "huang ye" },
            { text = "黄叶", comment = "huang ye" },
            { text = "黄烨", comment = "huang ye" },
            { text = "皇爷", comment = "huang ye" },
            { text = "黄晔", comment = "huang ye" },
            { text = "黄业", comment = "huang ye" },
            { text = "黄爷", comment = "huang ye" },
        },
        ["hui a"] = {
            { text = "会啊", comment = "hui a" },
            { text = "回啊", comment = "hui a" },
        },
        ["hui an"] = {
            { text = "惠安", comment = "hui an" },
            { text = "灰暗", comment = "hui an" },
            { text = "会按", comment = "hui an" },
            { text = "晦暗", comment = "hui an" },
            { text = "汇安", comment = "hui an" },
            { text = "慧安", comment = "hui an" },
            { text = "会安", comment = "hui an" },
        },
        ["hui an li"] = {
            { text = "惠安里", comment = "hui an li" },
        },
        ["hui ang"] = {
            { text = "辉昂", comment = "hui ang" },
        },
        ["hui bu"] = {
            { text = "会不", comment = "hui bu" },
            { text = "回不", comment = "hui bu" },
            { text = "回补", comment = "hui bu" },
            { text = "会补", comment = "hui bu" },
            { text = "灰埠", comment = "hui bu" },
            { text = "灰布", comment = "hui bu" },
        },
        ["hui e"] = {
            { text = "会饿", comment = "hui e" },
        },
        ["hui huai"] = {
            { text = "毁坏", comment = "hui huai" },
            { text = "会坏", comment = "hui huai" },
        },
        ["hui ne"] = {
            { text = "会呢", comment = "hui ne" },
            { text = "回呢", comment = "hui ne" },
        },
        ["hui ou"] = {
            { text = "惠欧", comment = "hui ou" },
            { text = "惠欧", comment = "hui ou" },
        },
        ["hui ri"] = {
            { text = "汇日", comment = "hui ri" },
        },
        ["hui xu"] = {
            { text = "回叙", comment = "hui xu" },
            { text = "会序", comment = "hui xu" },
            { text = "汇旭", comment = "hui xu" },
        },
        ["hui yu"] = {
            { text = "会与", comment = "hui yu" },
            { text = "惠誉", comment = "hui yu" },
            { text = "鮰鱼", comment = "hui yu" },
            { text = "毁于", comment = "hui yu" },
            { text = "汇宇", comment = "hui yu" },
            { text = "慧宇", comment = "hui yu" },
            { text = "慧鱼", comment = "hui yu" },
            { text = "惠宇", comment = "hui yu" },
            { text = "慧玉", comment = "hui yu" },
            { text = "辉宇", comment = "hui yu" },
            { text = "回鱼", comment = "hui yu" },
            { text = "惠玉", comment = "hui yu" },
            { text = "汇裕", comment = "hui yu" },
            { text = "秽语", comment = "hui yu" },
            { text = "灰羽", comment = "hui yu" },
            { text = "慧与", comment = "hui yu" },
            { text = "毁誉", comment = "hui yu" },
            { text = "惠禹", comment = "hui yu" },
        },
        ["hun a"] = {
            { text = "混啊", comment = "hun a" },
        },
        ["hun an"] = {
            { text = "昏暗", comment = "hun an" },
        },
        ["hun an de"] = {
            { text = "昏暗的", comment = "hun an de" },
        },
        ["hun di"] = {
            { text = "魂帝", comment = "hun di" },
        },
        ["hun xu"] = {
            { text = "魂虚", comment = "hun xu" },
        },
        ["hun ye"] = {
            { text = "混野", comment = "hun ye" },
            { text = "混业", comment = "hun ye" },
        },
        ["hun yu"] = {
            { text = "婚育", comment = "hun yu" },
            { text = "魂玉", comment = "hun yu" },
            { text = "混浴", comment = "hun yu" },
        },
        ["huo a"] = {
            { text = "火啊", comment = "huo a" },
        },
        ["huo ai"] = {
            { text = "或爱", comment = "huo ai" },
        },
        ["huo an"] = {
            { text = "霍安", comment = "huo an" },
            { text = "或按", comment = "huo an" },
        },
        ["huo an shi"] = {
            { text = "或暗示", comment = "huo an shi" },
        },
        ["huo di"] = {
            { text = "霍地", comment = "huo di" },
            { text = "货底", comment = "huo di" },
            { text = "活底", comment = "huo di" },
        },
        ["huo en"] = {
            { text = "霍恩", comment = "huo en" },
        },
        ["huo fo"] = {
            { text = "活佛", comment = "huo fo" },
        },
        ["huo yu"] = {
            { text = "活鱼", comment = "huo yu" },
            { text = "火雨", comment = "huo yu" },
            { text = "或与", comment = "huo yu" },
            { text = "火羽", comment = "huo yu" },
            { text = "火玉", comment = "huo yu" },
        },
        ["ji bu"] = {
            { text = "几部", comment = "ji bu" },
            { text = "几步", comment = "ji bu" },
            { text = "既不", comment = "ji bu" },
            { text = "级部", comment = "ji bu" },
            { text = "疾步", comment = "ji bu" },
            { text = "计步", comment = "ji bu" },
            { text = "基部", comment = "ji bu" },
            { text = "基布", comment = "ji bu" },
            { text = "极不", comment = "ji bu" },
            { text = "季布", comment = "ji bu" },
            { text = "缉捕", comment = "ji bu" },
            { text = "迹部", comment = "ji bu" },
            { text = "吉布", comment = "ji bu" },
            { text = "机补", comment = "ji bu" },
            { text = "集部", comment = "ji bu" },
            { text = "吉埠", comment = "ji bu" },
            { text = "即不", comment = "ji bu" },
        },
        ["ji da"] = {
            { text = "极大", comment = "ji da" },
            { text = "几大", comment = "ji da" },
            { text = "机打", comment = "ji da" },
            { text = "击打", comment = "ji da" },
            { text = "吉大", comment = "ji da" },
            { text = "暨大", comment = "ji da" },
            { text = "吉达", comment = "ji da" },
            { text = "集大", comment = "ji da" },
            { text = "济大", comment = "ji da" },
            { text = "积大", comment = "ji da" },
            { text = "吉打", comment = "ji da" },
        },
        ["ji da di"] = {
            { text = "极大地", comment = "ji da di" },
        },
        ["ji dai"] = {
            { text = "系带", comment = "ji dai" },
            { text = "几代", comment = "ji dai" },
            { text = "亟待", comment = "ji dai" },
            { text = "几袋", comment = "ji dai" },
            { text = "基带", comment = "ji dai" },
            { text = "及贷", comment = "ji dai" },
            { text = "继代", comment = "ji dai" },
        },
        ["ji dan"] = {
            { text = "鸡蛋", comment = "ji dan" },
            { text = "几单", comment = "ji dan" },
            { text = "急单", comment = "ji dan" },
            { text = "忌惮", comment = "ji dan" },
            { text = "寄单", comment = "ji dan" },
            { text = "基蛋", comment = "ji dan" },
            { text = "集单", comment = "ji dan" },
            { text = "季丹", comment = "ji dan" },
        },
        ["ji dao"] = {
            { text = "寄到", comment = "ji dao" },
            { text = "记到", comment = "ji dao" },
            { text = "几道", comment = "ji dao" },
            { text = "挤到", comment = "ji dao" },
            { text = "击倒", comment = "ji dao" },
            { text = "几刀", comment = "ji dao" },
            { text = "急到", comment = "ji dao" },
            { text = "即到", comment = "ji dao" },
            { text = "极道", comment = "ji dao" },
            { text = "几岛", comment = "ji dao" },
            { text = "缉盗", comment = "ji dao" },
            { text = "鸡刀", comment = "ji dao" },
            { text = "机道", comment = "ji dao" },
            { text = "急道", comment = "ji dao" },
            { text = "机刀", comment = "ji dao" },
            { text = "计导", comment = "ji dao" },
            { text = "辑盗", comment = "ji dao" },
        },
        ["ji de"] = {
            { text = "记得", comment = "ji de" },
            { text = "急得", comment = "ji de" },
            { text = "寄的", comment = "ji de" },
            { text = "急的", comment = "ji de" },
            { text = "级的", comment = "ji de" },
            { text = "挤得", comment = "ji de" },
            { text = "基德", comment = "ji de" },
            { text = "记的", comment = "ji de" },
            { text = "积德", comment = "ji de" },
            { text = "即得", comment = "ji de" },
            { text = "集的", comment = "ji de" },
            { text = "寄得", comment = "ji de" },
            { text = "机的", comment = "ji de" },
            { text = "既得", comment = "ji de" },
            { text = "鸡的", comment = "ji de" },
            { text = "吉德", comment = "ji de" },
            { text = "纪德", comment = "ji de" },
            { text = "己的", comment = "ji de" },
            { text = "冀德", comment = "ji de" },
        },
        ["ji de a"] = {
            { text = "记得啊", comment = "ji de a" },
        },
        ["ji de o"] = {
            { text = "记得哦", comment = "ji de o" },
        },
        ["ji de wo"] = {
            { text = "记得我", comment = "ji de wo" },
        },
        ["ji di bu"] = {
            { text = "基底部", comment = "ji di bu" },
        },
        ["ji die"] = {
            { text = "急跌", comment = "ji die" },
        },
        ["ji diu"] = {
            { text = "寄丢", comment = "ji diu" },
            { text = "鸡丢", comment = "ji diu" },
        },
        ["ji dou"] = {
            { text = "激斗", comment = "ji dou" },
            { text = "箕斗", comment = "ji dou" },
            { text = "几斗", comment = "ji dou" },
            { text = "鸡痘", comment = "ji dou" },
            { text = "极豆", comment = "ji dou" },
            { text = "偈都", comment = "ji dou" },
        },
        ["ji duan"] = {
            { text = "极端", comment = "ji duan" },
            { text = "几段", comment = "ji duan" },
            { text = "极短", comment = "ji duan" },
        },
        ["ji duo"] = {
            { text = "几多", comment = "ji duo" },
            { text = "几朵", comment = "ji duo" },
            { text = "极多", comment = "ji duo" },
            { text = "基多", comment = "ji duo" },
        },
        ["ji duo qian"] = {
            { text = "几多钱", comment = "ji duo qian" },
        },
        ["ji e"] = {
            { text = "饥饿", comment = "ji e" },
        },
        ["ji e du shi"] = {
            { text = "极恶都市", comment = "ji e du shi" },
        },
        ["ji e gan"] = {
            { text = "饥饿感", comment = "ji e gan" },
        },
        ["ji e sha"] = {
            { text = "饥饿鲨", comment = "ji e sha" },
        },
        ["ji er an"] = {
            { text = "己二胺", comment = "ji er an" },
        },
        ["ji hua bu"] = {
            { text = "计划部", comment = "ji hua bu" },
        },
        ["ji huai"] = {
            { text = "极坏", comment = "ji huai" },
            { text = "寄怀", comment = "ji huai" },
        },
        ["ji na"] = {
            { text = "缉拿", comment = "ji na" },
            { text = "吉娜", comment = "ji na" },
            { text = "基纳", comment = "ji na" },
            { text = "姬娜", comment = "ji na" },
            { text = "纪娜", comment = "ji na" },
        },
        ["ji nai"] = {
            { text = "挤奶", comment = "ji nai" },
            { text = "几耐", comment = "ji nai" },
        },
        ["ji nan"] = {
            { text = "济南", comment = "ji nan" },
            { text = "暨南", comment = "ji nan" },
            { text = "极难", comment = "ji nan" },
            { text = "冀南", comment = "ji nan" },
            { text = "急难", comment = "ji nan" },
            { text = "纪南", comment = "ji nan" },
            { text = "极男", comment = "ji nan" },
        },
        ["ji nan lu"] = {
            { text = "济南路", comment = "ji nan lu" },
        },
        ["ji nao"] = {
            { text = "激恼", comment = "ji nao" },
        },
        ["ji nei"] = {
            { text = "机内", comment = "ji nei" },
            { text = "肌内", comment = "ji nei" },
        },
        ["ji nie"] = {
            { text = "挤捏", comment = "ji nie" },
        },
        ["ji nin"] = {
            { text = "及您", comment = "ji nin" },
        },
        ["ji niu"] = {
            { text = "急钮", comment = "ji niu" },
            { text = "吉牛", comment = "ji niu" },
            { text = "基纽", comment = "ji niu" },
        },
        ["ji nuan"] = {
            { text = "集暖", comment = "ji nuan" },
        },
        ["ji nuo"] = {
            { text = "基诺", comment = "ji nuo" },
            { text = "吉诺", comment = "ji nuo" },
            { text = "济诺", comment = "ji nuo" },
            { text = "季诺", comment = "ji nuo" },
            { text = "技诺", comment = "ji nuo" },
        },
        ["ji ou"] = {
            { text = "奇偶", comment = "ji ou" },
            { text = "吉欧", comment = "ji ou" },
        },
        ["ji ri"] = {
            { text = "几日", comment = "ji ri" },
            { text = "即日", comment = "ji ri" },
            { text = "忌日", comment = "ji ri" },
            { text = "吉日", comment = "ji ri" },
            { text = "祭日", comment = "ji ri" },
            { text = "集日", comment = "ji ri" },
        },
        ["ji rou"] = {
            { text = "肌肉", comment = "ji rou" },
            { text = "鸡肉", comment = "ji rou" },
            { text = "基柔", comment = "ji rou" },
        },
        ["ji tai"] = {
            { text = "几台", comment = "ji tai" },
            { text = "机台", comment = "ji tai" },
            { text = "吉泰", comment = "ji tai" },
            { text = "基台", comment = "ji tai" },
            { text = "基态", comment = "ji tai" },
            { text = "肌肽", comment = "ji tai" },
            { text = "祭台", comment = "ji tai" },
            { text = "集泰", comment = "ji tai" },
            { text = "叽太", comment = "ji tai" },
            { text = "济泰", comment = "ji tai" },
            { text = "基泰", comment = "ji tai" },
            { text = "纪台", comment = "ji tai" },
            { text = "吉太", comment = "ji tai" },
            { text = "极泰", comment = "ji tai" },
        },
        ["ji tan"] = {
            { text = "祭坛", comment = "ji tan" },
            { text = "积碳", comment = "ji tan" },
            { text = "汲滩", comment = "ji tan" },
        },
        ["ji tao"] = {
            { text = "几套", comment = "ji tao" },
            { text = "机套", comment = "ji tao" },
            { text = "纪涛", comment = "ji tao" },
            { text = "季涛", comment = "ji tao" },
            { text = "吉涛", comment = "ji tao" },
            { text = "继涛", comment = "ji tao" },
        },
        ["ji te"] = {
            { text = "吉特", comment = "ji te" },
        },
        ["ji tie"] = {
            { text = "几贴", comment = "ji tie" },
            { text = "机贴", comment = "ji tie" },
            { text = "肌贴", comment = "ji tie" },
        },
        ["ji tou"] = {
            { text = "机头", comment = "ji tou" },
            { text = "鸡头", comment = "ji tou" },
            { text = "几头", comment = "ji tou" },
            { text = "机投", comment = "ji tou" },
            { text = "基头", comment = "ji tou" },
            { text = "基投", comment = "ji tou" },
        },
        ["ji tuan"] = {
            { text = "集团", comment = "ji tuan" },
            { text = "基团", comment = "ji tuan" },
            { text = "级团", comment = "ji tuan" },
            { text = "急湍", comment = "ji tuan" },
        },
        ["ji tuo"] = {
            { text = "寄托", comment = "ji tuo" },
            { text = "几坨", comment = "ji tuo" },
            { text = "基托", comment = "ji tuo" },
        },
        ["ji wa"] = {
            { text = "鸡娃", comment = "ji wa" },
            { text = "脊瓦", comment = "ji wa" },
            { text = "几瓦", comment = "ji wa" },
            { text = "吉娃", comment = "ji wa" },
        },
        ["ji wai"] = {
            { text = "叽歪", comment = "ji wai" },
        },
        ["ji wan"] = {
            { text = "几万", comment = "ji wan" },
            { text = "几晚", comment = "ji wan" },
            { text = "寄完", comment = "ji wan" },
            { text = "几碗", comment = "ji wan" },
            { text = "记完", comment = "ji wan" },
            { text = "急弯", comment = "ji wan" },
            { text = "己烷", comment = "ji wan" },
            { text = "鸡丸", comment = "ji wan" },
            { text = "集完", comment = "ji wan" },
        },
        ["ji wei"] = {
            { text = "纪委", comment = "ji wei" },
            { text = "几位", comment = "ji wei" },
            { text = "即为", comment = "ji wei" },
            { text = "极为", comment = "ji wei" },
            { text = "机位", comment = "ji wei" },
            { text = "记为", comment = "ji wei" },
            { text = "机尾", comment = "ji wei" },
            { text = "继位", comment = "ji wei" },
            { text = "继伟", comment = "ji wei" },
            { text = "即位", comment = "ji wei" },
            { text = "纪伟", comment = "ji wei" },
            { text = "计委", comment = "ji wei" },
            { text = "鸡尾", comment = "ji wei" },
            { text = "季伟", comment = "ji wei" },
            { text = "计为", comment = "ji wei" },
            { text = "吉威", comment = "ji wei" },
            { text = "基围", comment = "ji wei" },
            { text = "己未", comment = "ji wei" },
            { text = "吉伟", comment = "ji wei" },
            { text = "既为", comment = "ji wei" },
            { text = "级位", comment = "ji wei" },
            { text = "积微", comment = "ji wei" },
            { text = "基伟", comment = "ji wei" },
            { text = "姬伟", comment = "ji wei" },
        },
        ["ji wen"] = {
            { text = "激吻", comment = "ji wen" },
            { text = "继文", comment = "ji wen" },
            { text = "吉文", comment = "ji wen" },
            { text = "祭文", comment = "ji wen" },
            { text = "积温", comment = "ji wen" },
            { text = "鸡瘟", comment = "ji wen" },
            { text = "纪文", comment = "ji wen" },
            { text = "季文", comment = "ji wen" },
            { text = "集文", comment = "ji wen" },
            { text = "急问", comment = "ji wen" },
            { text = "纪闻", comment = "ji wen" },
        },
        ["jia ba"] = {
            { text = "加吧", comment = "jia ba" },
            { text = "家吧", comment = "jia ba" },
            { text = "假吧", comment = "jia ba" },
            { text = "贾巴", comment = "jia ba" },
        },
        ["jia bai"] = {
            { text = "加白", comment = "jia bai" },
            { text = "假白", comment = "jia bai" },
            { text = "佳佰", comment = "jia bai" },
            { text = "甲白", comment = "jia bai" },
            { text = "嘉柏", comment = "jia bai" },
        },
        ["jia ban"] = {
            { text = "加班", comment = "jia ban" },
            { text = "夹板", comment = "jia ban" },
            { text = "甲板", comment = "jia ban" },
            { text = "甲班", comment = "jia ban" },
            { text = "假扮", comment = "jia ban" },
            { text = "架板", comment = "jia ban" },
            { text = "家办", comment = "jia ban" },
        },
        ["jia ban ban"] = {
            { text = "加班班", comment = "jia ban ban" },
        },
        ["jia ban xiang"] = {
            { text = "夹板箱", comment = "jia ban xiang" },
        },
        ["jia bang"] = {
            { text = "加帮", comment = "jia bang" },
            { text = "佳邦", comment = "jia bang" },
            { text = "嘉邦", comment = "jia bang" },
        },
        ["jia bao"] = {
            { text = "家暴", comment = "jia bao" },
            { text = "嘉宝", comment = "jia bao" },
            { text = "价保", comment = "jia bao" },
            { text = "加保", comment = "jia bao" },
            { text = "佳宝", comment = "jia bao" },
            { text = "家宝", comment = "jia bao" },
            { text = "加包", comment = "jia bao" },
            { text = "加报", comment = "jia bao" },
            { text = "加爆", comment = "jia bao" },
            { text = "加宝", comment = "jia bao" },
            { text = "夹报", comment = "jia bao" },
            { text = "夹包", comment = "jia bao" },
            { text = "嘉保", comment = "jia bao" },
            { text = "家报", comment = "jia bao" },
        },
        ["jia bao le"] = {
            { text = "假爆了", comment = "jia bao le" },
        },
        ["jia bei"] = {
            { text = "加倍", comment = "jia bei" },
            { text = "加呗", comment = "jia bei" },
            { text = "佳贝", comment = "jia bei" },
            { text = "加贝", comment = "jia bei" },
            { text = "嘉北", comment = "jia bei" },
            { text = "嘉贝", comment = "jia bei" },
            { text = "嘉倍", comment = "jia bei" },
            { text = "夹被", comment = "jia bei" },
            { text = "佳蓓", comment = "jia bei" },
        },
        ["jia ben"] = {
            { text = "甲苯", comment = "jia ben" },
            { text = "加本", comment = "jia ben" },
        },
        ["jia bi you"] = {
            { text = "嘉必优", comment = "jia bi you" },
        },
        ["jia bin"] = {
            { text = "嘉宾", comment = "jia bin" },
            { text = "贾斌", comment = "jia bin" },
            { text = "佳斌", comment = "jia bin" },
            { text = "佳彬", comment = "jia bin" },
            { text = "贾彬", comment = "jia bin" },
            { text = "嘉斌", comment = "jia bin" },
            { text = "家斌", comment = "jia bin" },
            { text = "嘉彬", comment = "jia bin" },
            { text = "家彬", comment = "jia bin" },
        },
        ["jia bin lu"] = {
            { text = "嘉宾路", comment = "jia bin lu" },
        },
        ["jia bin xi"] = {
            { text = "嘉宾席", comment = "jia bin xi" },
        },
        ["jia bin zheng"] = {
            { text = "嘉宾证", comment = "jia bin zheng" },
        },
        ["jia bo"] = {
            { text = "加拨", comment = "jia bo" },
            { text = "佳博", comment = "jia bo" },
            { text = "嘉博", comment = "jia bo" },
            { text = "贾波", comment = "jia bo" },
            { text = "贾博", comment = "jia bo" },
            { text = "加波", comment = "jia bo" },
            { text = "佳波", comment = "jia bo" },
            { text = "嘉柏", comment = "jia bo" },
            { text = "家波", comment = "jia bo" },
        },
        ["jia bu"] = {
            { text = "加布", comment = "jia bu" },
            { text = "加不", comment = "jia bu" },
            { text = "夹布", comment = "jia bu" },
            { text = "甲部", comment = "jia bu" },
        },
        ["jia nai"] = {
            { text = "加奶", comment = "jia nai" },
            { text = "加奈", comment = "jia nai" },
        },
        ["jia nan"] = {
            { text = "迦南", comment = "jia nan" },
            { text = "佳楠", comment = "jia nan" },
            { text = "贾楠", comment = "jia nan" },
            { text = "嘉楠", comment = "jia nan" },
            { text = "佳男", comment = "jia nan" },
            { text = "佳南", comment = "jia nan" },
            { text = "嘉南", comment = "jia nan" },
        },
        ["jia ne"] = {
            { text = "家呢", comment = "jia ne" },
        },
        ["jia nei"] = {
            { text = "加内", comment = "jia nei" },
        },
        ["jia nie"] = {
            { text = "加涅", comment = "jia nie" },
        },
        ["jia nin"] = {
            { text = "加您", comment = "jia nin" },
        },
        ["jia nuan"] = {
            { text = "贾暖", comment = "jia nuan" },
        },
        ["jia nuo"] = {
            { text = "佳诺", comment = "jia nuo" },
            { text = "嘉诺", comment = "jia nuo" },
        },
        ["jia ou"] = {
            { text = "佳偶", comment = "jia ou" },
        },
        ["jia ta"] = {
            { text = "加他", comment = "jia ta" },
            { text = "加她", comment = "jia ta" },
        },
        ["jia tai"] = {
            { text = "嘉泰", comment = "jia tai" },
            { text = "佳泰", comment = "jia tai" },
            { text = "价态", comment = "jia tai" },
            { text = "架台", comment = "jia tai" },
            { text = "加泰", comment = "jia tai" },
            { text = "家泰", comment = "jia tai" },
            { text = "珈泰", comment = "jia tai" },
        },
        ["jia tan"] = {
            { text = "贾滩", comment = "jia tan" },
        },
        ["jia te"] = {
            { text = "加特", comment = "jia te" },
            { text = "嘉特", comment = "jia te" },
            { text = "佳特", comment = "jia te" },
        },
        ["jia tie"] = {
            { text = "加贴", comment = "jia tie" },
            { text = "甲铁", comment = "jia tie" },
        },
        ["jia tou"] = {
            { text = "夹头", comment = "jia tou" },
            { text = "家头", comment = "jia tou" },
        },
        ["jia tuan"] = {
            { text = "加团", comment = "jia tuan" },
        },
        ["jia tuo"] = {
            { text = "嘉拓", comment = "jia tuo" },
            { text = "夹拖", comment = "jia tuo" },
            { text = "加托", comment = "jia tuo" },
            { text = "假托", comment = "jia tuo" },
            { text = "甲托", comment = "jia tuo" },
        },
        ["jian ai"] = {
            { text = "简爱", comment = "jian ai" },
            { text = "兼爱", comment = "jian ai" },
            { text = "剪爱", comment = "jian ai" },
        },
        ["jian an"] = {
            { text = "建安", comment = "jian an" },
            { text = "简案", comment = "jian an" },
            { text = "健安", comment = "jian an" },
            { text = "检安", comment = "jian an" },
        },
        ["jian bu"] = {
            { text = "肩部", comment = "jian bu" },
            { text = "健步", comment = "jian bu" },
            { text = "箭步", comment = "jian bu" },
            { text = "剪布", comment = "jian bu" },
        },
        ["jian di"] = {
            { text = "减低", comment = "jian di" },
            { text = "剑帝", comment = "jian di" },
            { text = "见底", comment = "jian di" },
            { text = "见地", comment = "jian di" },
            { text = "尖底", comment = "jian di" },
            { text = "歼敌", comment = "jian di" },
            { text = "捡底", comment = "jian di" },
            { text = "碱地", comment = "jian di" },
        },
        ["jian e"] = {
            { text = "奸恶", comment = "jian e" },
            { text = "减额", comment = "jian e" },
        },
        ["jian huai"] = {
            { text = "剪坏", comment = "jian huai" },
        },
        ["jian ou"] = {
            { text = "简欧", comment = "jian ou" },
            { text = "建瓯", comment = "jian ou" },
        },
        ["jian ri"] = {
            { text = "间日", comment = "jian ri" },
            { text = "舰日", comment = "jian ri" },
        },
        ["jian wo"] = {
            { text = "见我", comment = "jian wo" },
            { text = "肩窝", comment = "jian wo" },
        },
        ["jian xu"] = {
            { text = "建旭", comment = "jian xu" },
        },
        ["jian ye"] = {
            { text = "建业", comment = "jian ye" },
            { text = "建邺", comment = "jian ye" },
            { text = "碱液", comment = "jian ye" },
            { text = "兼业", comment = "jian ye" },
            { text = "碱业", comment = "jian ye" },
            { text = "健业", comment = "jian ye" },
        },
        ["jian yu"] = {
            { text = "鉴于", comment = "jian yu" },
            { text = "监狱", comment = "jian yu" },
            { text = "建于", comment = "jian yu" },
            { text = "见于", comment = "jian yu" },
            { text = "剑雨", comment = "jian yu" },
            { text = "建宇", comment = "jian yu" },
            { text = "煎鱼", comment = "jian yu" },
            { text = "剑鱼", comment = "jian yu" },
            { text = "箭雨", comment = "jian yu" },
            { text = "鲣鱼", comment = "jian yu" },
            { text = "剑域", comment = "jian yu" },
            { text = "健宇", comment = "jian yu" },
            { text = "剑宇", comment = "jian yu" },
            { text = "建玉", comment = "jian yu" },
            { text = "建雨", comment = "jian yu" },
            { text = "剑玉", comment = "jian yu" },
        },
        ["jiang a"] = {
            { text = "讲啊", comment = "jiang a" },
        },
        ["jiang ai"] = {
            { text = "将爱", comment = "jiang ai" },
            { text = "姜艾", comment = "jiang ai" },
        },
        ["jiang an"] = {
            { text = "江安", comment = "jiang an" },
            { text = "江岸", comment = "jiang an" },
            { text = "将按", comment = "jiang an" },
        },
        ["jiang bu"] = {
            { text = "奖补", comment = "jiang bu" },
            { text = "讲不", comment = "jiang bu" },
            { text = "将不", comment = "jiang bu" },
            { text = "姜部", comment = "jiang bu" },
            { text = "蒋部", comment = "jiang bu" },
            { text = "江埔", comment = "jiang bu" },
        },
        ["jiang di"] = {
            { text = "降低", comment = "jiang di" },
            { text = "江堤", comment = "jiang di" },
            { text = "姜迪", comment = "jiang di" },
            { text = "蒋迪", comment = "jiang di" },
            { text = "江迪", comment = "jiang di" },
        },
        ["jiang e"] = {
            { text = "降额", comment = "jiang e" },
            { text = "奖额", comment = "jiang e" },
        },
        ["jiang ei"] = {
            { text = "将诶", comment = "jiang ei" },
        },
        ["jiang wo"] = {
            { text = "将我", comment = "jiang wo" },
            { text = "讲我", comment = "jiang wo" },
        },
        ["jiang xu"] = {
            { text = "降序", comment = "jiang xu" },
            { text = "姜旭", comment = "jiang xu" },
            { text = "蒋旭", comment = "jiang xu" },
            { text = "江旭", comment = "jiang xu" },
        },
        ["jiang ye"] = {
            { text = "将夜", comment = "jiang ye" },
            { text = "浆液", comment = "jiang ye" },
            { text = "桨叶", comment = "jiang ye" },
            { text = "讲野", comment = "jiang ye" },
            { text = "蒋烨", comment = "jiang ye" },
            { text = "江烨", comment = "jiang ye" },
            { text = "姜烨", comment = "jiang ye" },
            { text = "江野", comment = "jiang ye" },
            { text = "奖掖", comment = "jiang ye" },
        },
        ["jiao a"] = {
            { text = "交啊", comment = "jiao a" },
            { text = "叫啊", comment = "jiao a" },
        },
        ["jiao ai"] = {
            { text = "湫隘", comment = "jiao ai" },
            { text = "椒爱", comment = "jiao ai" },
        },
        ["jiao an"] = {
            { text = "教案", comment = "jiao an" },
            { text = "交安", comment = "jiao an" },
            { text = "叫俺", comment = "jiao an" },
        },
        ["jiao an ban"] = {
            { text = "交安办", comment = "jiao an ban" },
        },
        ["jiao an xiang"] = {
            { text = "胶暗箱", comment = "jiao an xiang" },
        },
        ["jiao ang"] = {
            { text = "焦昂", comment = "jiao ang" },
        },
        ["jiao ao"] = {
            { text = "骄傲", comment = "jiao ao" },
        },
        ["jiao ao le"] = {
            { text = "骄傲了", comment = "jiao ao le" },
        },
        ["jiao di"] = {
            { text = "较低", comment = "jiao di" },
            { text = "交底", comment = "jiao di" },
            { text = "脚底", comment = "jiao di" },
            { text = "浇地", comment = "jiao di" },
            { text = "交地", comment = "jiao di" },
            { text = "胶底", comment = "jiao di" },
            { text = "轿底", comment = "jiao di" },
        },
        ["jiao en"] = {
            { text = "焦恩", comment = "jiao en" },
        },
        ["jiao o"] = {
            { text = "叫哦", comment = "jiao o" },
        },
        ["jiao yi bu"] = {
            { text = "交易部", comment = "jiao yi bu" },
        },
        ["jiao yu"] = {
            { text = "教育", comment = "jiao yu" },
            { text = "交于", comment = "jiao yu" },
            { text = "交予", comment = "jiao yu" },
            { text = "交与", comment = "jiao yu" },
            { text = "皎玉", comment = "jiao yu" },
            { text = "焦宇", comment = "jiao yu" },
            { text = "脚鱼", comment = "jiao yu" },
        },
        ["jiao yu lu"] = {
            { text = "焦裕禄", comment = "jiao yu lu" },
            { text = "教育路", comment = "jiao yu lu" },
        },
        ["jiao yu xi"] = {
            { text = "教育系", comment = "jiao yu xi" },
        },
        ["jiao yu zheng"] = {
            { text = "教育证", comment = "jiao yu zheng" },
        },
        ["jie"] = {
            { text = "接", comment = "jie" },
            { text = "姐", comment = "jie" },
            { text = "借", comment = "jie" },
            { text = "节", comment = "jie" },
            { text = "结", comment = "jie" },
            { text = "解", comment = "jie" },
            { text = "街", comment = "jie" },
            { text = "杰", comment = "jie" },
            { text = "界", comment = "jie" },
            { text = "截", comment = "jie" },
            { text = "届", comment = "jie" },
            { text = "洁", comment = "jie" },
            { text = "戒", comment = "jie" },
            { text = "介", comment = "jie" },
            { text = "皆", comment = "jie" },
            { text = "捷", comment = "jie" },
            { text = "劫", comment = "jie" },
            { text = "阶", comment = "jie" },
            { text = "揭", comment = "jie" },
            { text = "婕", comment = "jie" },
            { text = "嗟", comment = "jie" },
            { text = "竭", comment = "jie" },
            { text = "诫", comment = "jie" },
            { text = "桀", comment = "jie" },
            { text = "劼", comment = "jie" },
            { text = "芥", comment = "jie" },
            { text = "颉", comment = "jie" },
            { text = "孑", comment = "jie" },
            { text = "喈", comment = "jie" },
            { text = "藉", comment = "jie" },
            { text = "桔", comment = "jie" },
            { text = "羯", comment = "jie" },
            { text = "诘", comment = "jie" },
            { text = "睫", comment = "jie" },
            { text = "碣", comment = "jie" },
            { text = "秸", comment = "jie" },
            { text = "疖", comment = "jie" },
            { text = "卩", comment = "jie" },
            { text = "偈", comment = "jie" },
            { text = "疥", comment = "jie" },
            { text = "蚧", comment = "jie" },
            { text = "玠", comment = "jie" },
            { text = "拮", comment = "jie" },
            { text = "悈", comment = "jie" },
            { text = "檞", comment = "jie" },
            { text = "讦", comment = "jie" },
            { text = "鲒", comment = "jie" },
            { text = "价", comment = "jie" },
            { text = "岊", comment = "jie" },
            { text = "哜", comment = "jie" },
            { text = "骱", comment = "jie" },
            { text = "湝", comment = "jie" },
            { text = "蜐", comment = "jie" },
            { text = "褯", comment = "jie" },
            { text = "㛃", comment = "jie" },
            { text = "寁", comment = "jie" },
            { text = "耤", comment = "jie" },
        },
        ["jie a"] = {
            { text = "接啊", comment = "jie a" },
            { text = "姐啊", comment = "jie a" },
        },
        ["jie ai"] = {
            { text = "节哀", comment = "jie ai" },
            { text = "结爱", comment = "jie ai" },
        },
        ["jie an"] = {
            { text = "结案", comment = "jie an" },
            { text = "捷安", comment = "jie an" },
            { text = "接案", comment = "jie an" },
            { text = "劫案", comment = "jie an" },
            { text = "杰安", comment = "jie an" },
            { text = "洁安", comment = "jie an" },
        },
        ["jie ao"] = {
            { text = "桀骜", comment = "jie ao" },
            { text = "杰奥", comment = "jie ao" },
            { text = "捷奥", comment = "jie ao" },
        },
        ["jie ban"] = {
            { text = "接班", comment = "jie ban" },
            { text = "结伴", comment = "jie ban" },
            { text = "街办", comment = "jie ban" },
            { text = "结班", comment = "jie ban" },
            { text = "接办", comment = "jie ban" },
            { text = "结办", comment = "jie ban" },
            { text = "解斑", comment = "jie ban" },
            { text = "解班", comment = "jie ban" },
        },
        ["jie bu"] = {
            { text = "杰布", comment = "jie bu" },
            { text = "接不", comment = "jie bu" },
            { text = "借不", comment = "jie bu" },
            { text = "揭不", comment = "jie bu" },
        },
        ["jie da"] = {
            { text = "解答", comment = "jie da" },
            { text = "捷达", comment = "jie da" },
            { text = "接打", comment = "jie da" },
            { text = "杰达", comment = "jie da" },
            { text = "杰大", comment = "jie da" },
            { text = "洁达", comment = "jie da" },
            { text = "皆大", comment = "jie da" },
            { text = "捷大", comment = "jie da" },
        },
        ["jie du shi"] = {
            { text = "节度使", comment = "jie du shi" },
        },
        ["jie duo"] = {
            { text = "劫夺", comment = "jie duo" },
        },
        ["jie e"] = {
            { text = "解饿", comment = "jie e" },
        },
        ["jie er"] = {
            { text = "洁儿", comment = "jie er" },
            { text = "姐儿", comment = "jie er" },
            { text = "杰儿", comment = "jie er" },
            { text = "杰尔", comment = "jie er" },
            { text = "捷尔", comment = "jie er" },
            { text = "洁尔", comment = "jie er" },
        },
        ["jie fei"] = {
            { text = "劫匪", comment = "jie fei" },
            { text = "结费", comment = "jie fei" },
            { text = "捷飞", comment = "jie fei" },
            { text = "皆非", comment = "jie fei" },
            { text = "杰飞", comment = "jie fei" },
        },
        ["jie gan"] = {
            { text = "秸秆", comment = "jie gan" },
            { text = "接杆", comment = "jie gan" },
            { text = "借杆", comment = "jie gan" },
        },
        ["jie huai"] = {
            { text = "介怀", comment = "jie huai" },
        },
        ["jie ou"] = {
            { text = "解耦", comment = "jie ou" },
        },
        ["jie ri"] = {
            { text = "节日", comment = "jie ri" },
        },
        ["jie sha"] = {
            { text = "截杀", comment = "jie sha" },
            { text = "接啥", comment = "jie sha" },
            { text = "劫煞", comment = "jie sha" },
        },
        ["jie wo"] = {
            { text = "借我", comment = "jie wo" },
            { text = "接我", comment = "jie wo" },
            { text = "捷沃", comment = "jie wo" },
        },
        ["jie wo qian"] = {
            { text = "借我钱", comment = "jie wo qian" },
        },
        ["jie xu"] = {
            { text = "接续", comment = "jie xu" },
        },
        ["jie ye"] = {
            { text = "结业", comment = "jie ye" },
        },
        ["jie you"] = {
            { text = "皆有", comment = "jie you" },
            { text = "解忧", comment = "jie you" },
            { text = "借由", comment = "jie you" },
            { text = "节油", comment = "jie you" },
            { text = "藉由", comment = "jie you" },
            { text = "接油", comment = "jie you" },
            { text = "皆由", comment = "jie you" },
            { text = "捷优", comment = "jie you" },
        },
        ["jie yu"] = {
            { text = "结余", comment = "jie yu" },
            { text = "介于", comment = "jie yu" },
            { text = "结语", comment = "jie yu" },
            { text = "婕妤", comment = "jie yu" },
            { text = "节育", comment = "jie yu" },
            { text = "节余", comment = "jie yu" },
            { text = "劫狱", comment = "jie yu" },
            { text = "洁玉", comment = "jie yu" },
            { text = "借喻", comment = "jie yu" },
            { text = "解郁", comment = "jie yu" },
            { text = "捷宇", comment = "jie yu" },
            { text = "解语", comment = "jie yu" },
            { text = "杰宇", comment = "jie yu" },
            { text = "界域", comment = "jie yu" },
            { text = "洁瑜", comment = "jie yu" },
            { text = "洁宇", comment = "jie yu" },
            { text = "节欲", comment = "jie yu" },
            { text = "倢伃", comment = "jie yu" },
        },
        ["jin a"] = {
            { text = "进啊", comment = "jin a" },
        },
        ["jin ai"] = {
            { text = "紧挨", comment = "jin ai" },
        },
        ["jin an"] = {
            { text = "晋安", comment = "jin an" },
            { text = "金安", comment = "jin an" },
            { text = "金岸", comment = "jin an" },
            { text = "锦安", comment = "jin an" },
            { text = "锦氨", comment = "jin an" },
        },
        ["jin an lu"] = {
            { text = "晋安路", comment = "jin an lu" },
        },
        ["jin ao"] = {
            { text = "金奥", comment = "jin ao" },
            { text = "金澳", comment = "jin ao" },
        },
        ["jin bu"] = {
            { text = "进步", comment = "jin bu" },
            { text = "进不", comment = "jin bu" },
            { text = "进补", comment = "jin bu" },
            { text = "近不", comment = "jin bu" },
            { text = "金布", comment = "jin bu" },
            { text = "金部", comment = "jin bu" },
            { text = "禁步", comment = "jin bu" },
            { text = "金步", comment = "jin bu" },
        },
        ["jin di"] = {
            { text = "金地", comment = "jin di" },
            { text = "禁地", comment = "jin di" },
            { text = "金帝", comment = "jin di" },
            { text = "金迪", comment = "jin di" },
            { text = "金娣", comment = "jin di" },
            { text = "近地", comment = "jin di" },
            { text = "金底", comment = "jin di" },
            { text = "金笛", comment = "jin di" },
            { text = "锦地", comment = "jin di" },
            { text = "金堤", comment = "jin di" },
            { text = "锦涤", comment = "jin di" },
            { text = "进抵", comment = "jin di" },
            { text = "金缔", comment = "jin di" },
        },
        ["jin fo"] = {
            { text = "金佛", comment = "jin fo" },
        },
        ["jin gu yuan"] = {
            { text = "金谷园", comment = "jin gu yuan" },
        },
        ["jin gui xu"] = {
            { text = "金龟婿", comment = "jin gui xu" },
        },
        ["jin hua ban"] = {
            { text = "进化版", comment = "jin hua ban" },
        },
        ["jin huai"] = {
            { text = "襟怀", comment = "jin huai" },
        },
        ["jin ou"] = {
            { text = "金瓯", comment = "jin ou" },
            { text = "金欧", comment = "jin ou" },
        },
        ["jin ri"] = {
            { text = "今日", comment = "jin ri" },
            { text = "近日", comment = "jin ri" },
            { text = "金日", comment = "jin ri" },
        },
        ["jin ri an"] = {
            { text = "今日安", comment = "jin ri an" },
        },
        ["jin shu yan"] = {
            { text = "金属盐", comment = "jin shu yan" },
        },
        ["jin shui an"] = {
            { text = "金水岸", comment = "jin shui an" },
        },
        ["jin wo"] = {
            { text = "进我", comment = "jin wo" },
            { text = "尽我", comment = "jin wo" },
            { text = "紧握", comment = "jin wo" },
            { text = "金沃", comment = "jin wo" },
            { text = "金窝", comment = "jin wo" },
        },
        ["jin xu"] = {
            { text = "仅需", comment = "jin xu" },
            { text = "金旭", comment = "jin xu" },
            { text = "锦旭", comment = "jin xu" },
        },
        ["jin ye"] = {
            { text = "今夜", comment = "jin ye" },
            { text = "金叶", comment = "jin ye" },
            { text = "金业", comment = "jin ye" },
            { text = "锦业", comment = "jin ye" },
            { text = "津液", comment = "jin ye" },
            { text = "进液", comment = "jin ye" },
            { text = "金烨", comment = "jin ye" },
            { text = "金爷", comment = "jin ye" },
            { text = "金晔", comment = "jin ye" },
            { text = "浸液", comment = "jin ye" },
            { text = "金冶", comment = "jin ye" },
            { text = "晋业", comment = "jin ye" },
            { text = "进业", comment = "jin ye" },
            { text = "晋谒", comment = "jin ye" },
        },
        ["jin yu"] = {
            { text = "金鱼", comment = "jin yu" },
            { text = "金域", comment = "jin yu" },
            { text = "金玉", comment = "jin yu" },
            { text = "禁欲", comment = "jin yu" },
            { text = "金宇", comment = "jin yu" },
            { text = "金隅", comment = "jin yu" },
            { text = "瑾瑜", comment = "jin yu" },
            { text = "金裕", comment = "jin yu" },
            { text = "金雨", comment = "jin yu" },
            { text = "金誉", comment = "jin yu" },
            { text = "禁渔", comment = "jin yu" },
            { text = "金钰", comment = "jin yu" },
            { text = "金羽", comment = "jin yu" },
            { text = "金渝", comment = "jin yu" },
            { text = "禁语", comment = "jin yu" },
            { text = "锦玉", comment = "jin yu" },
            { text = "金语", comment = "jin yu" },
            { text = "金御", comment = "jin yu" },
            { text = "锦宇", comment = "jin yu" },
            { text = "晋宇", comment = "jin yu" },
            { text = "锦钰", comment = "jin yu" },
            { text = "近于", comment = "jin yu" },
            { text = "金瑜", comment = "jin yu" },
            { text = "金昱", comment = "jin yu" },
            { text = "金余", comment = "jin yu" },
            { text = "金豫", comment = "jin yu" },
            { text = "今瑜", comment = "jin yu" },
            { text = "金屿", comment = "jin yu" },
            { text = "锦域", comment = "jin yu" },
            { text = "津瑜", comment = "jin yu" },
            { text = "金舆", comment = "jin yu" },
            { text = "禁娱", comment = "jin yu" },
            { text = "金煜", comment = "jin yu" },
            { text = "金鱼", comment = "jin yu" },
            { text = "金域", comment = "jin yu" },
            { text = "金玉", comment = "jin yu" },
            { text = "禁欲", comment = "jin yu" },
            { text = "金宇", comment = "jin yu" },
            { text = "金隅", comment = "jin yu" },
            { text = "瑾瑜", comment = "jin yu" },
            { text = "金裕", comment = "jin yu" },
            { text = "金雨", comment = "jin yu" },
            { text = "金誉", comment = "jin yu" },
            { text = "禁渔", comment = "jin yu" },
            { text = "金钰", comment = "jin yu" },
            { text = "金羽", comment = "jin yu" },
            { text = "金渝", comment = "jin yu" },
            { text = "禁语", comment = "jin yu" },
            { text = "锦玉", comment = "jin yu" },
            { text = "金语", comment = "jin yu" },
            { text = "金御", comment = "jin yu" },
            { text = "锦宇", comment = "jin yu" },
            { text = "晋宇", comment = "jin yu" },
            { text = "锦钰", comment = "jin yu" },
            { text = "近于", comment = "jin yu" },
            { text = "金瑜", comment = "jin yu" },
            { text = "金昱", comment = "jin yu" },
            { text = "金余", comment = "jin yu" },
            { text = "金豫", comment = "jin yu" },
            { text = "今瑜", comment = "jin yu" },
            { text = "金屿", comment = "jin yu" },
            { text = "锦域", comment = "jin yu" },
            { text = "津瑜", comment = "jin yu" },
            { text = "金舆", comment = "jin yu" },
            { text = "禁娱", comment = "jin yu" },
            { text = "金煜", comment = "jin yu" },
        },
        ["jing ai"] = {
            { text = "敬爱", comment = "jing ai" },
            { text = "菁爱", comment = "jing ai" },
        },
        ["jing an"] = {
            { text = "静安", comment = "jing an" },
            { text = "靖安", comment = "jing an" },
            { text = "井岸", comment = "jing an" },
            { text = "景安", comment = "jing an" },
            { text = "京安", comment = "jing an" },
            { text = "敬安", comment = "jing an" },
            { text = "晶安", comment = "jing an" },
            { text = "经安", comment = "jing an" },
            { text = "净安", comment = "jing an" },
        },
        ["jing ao"] = {
            { text = "晶澳", comment = "jing ao" },
            { text = "京奥", comment = "jing ao" },
        },
        ["jing bu"] = {
            { text = "颈部", comment = "jing bu" },
            { text = "静步", comment = "jing bu" },
            { text = "镜布", comment = "jing bu" },
            { text = "经部", comment = "jing bu" },
        },
        ["jing e"] = {
            { text = "净额", comment = "jing e" },
            { text = "惊愕", comment = "jing e" },
        },
        ["jing ou"] = {
            { text = "精欧", comment = "jing ou" },
        },
        ["jing wo"] = {
            { text = "静卧", comment = "jing wo" },
            { text = "颈窝", comment = "jing wo" },
        },
        ["jing xu"] = {
            { text = "景旭", comment = "jing xu" },
            { text = "晶须", comment = "jing xu" },
        },
        ["jing ye"] = {
            { text = "敬业", comment = "jing ye" },
            { text = "竞业", comment = "jing ye" },
            { text = "精液", comment = "jing ye" },
            { text = "静夜", comment = "jing ye" },
            { text = "茎叶", comment = "jing ye" },
            { text = "精业", comment = "jing ye" },
            { text = "景业", comment = "jing ye" },
            { text = "井野", comment = "jing ye" },
            { text = "竟业", comment = "jing ye" },
            { text = "京冶", comment = "jing ye" },
            { text = "竟也", comment = "jing ye" },
            { text = "静叶", comment = "jing ye" },
            { text = "兢业", comment = "jing ye" },
            { text = "净液", comment = "jing ye" },
        },
        ["jiu a"] = {
            { text = "久啊", comment = "jiu a" },
            { text = "就啊", comment = "jiu a" },
            { text = "酒啊", comment = "jiu a" },
        },
        ["jiu ai"] = {
            { text = "就爱", comment = "jiu ai" },
            { text = "旧爱", comment = "jiu ai" },
            { text = "久爱", comment = "jiu ai" },
        },
        ["jiu an"] = {
            { text = "就按", comment = "jiu an" },
            { text = "久安", comment = "jiu an" },
            { text = "九安", comment = "jiu an" },
            { text = "旧案", comment = "jiu an" },
            { text = "玖安", comment = "jiu an" },
        },
        ["jiu ao"] = {
            { text = "就熬", comment = "jiu ao" },
            { text = "酒凹", comment = "jiu ao" },
        },
        ["jiu bu"] = {
            { text = "就不", comment = "jiu bu" },
            { text = "就补", comment = "jiu bu" },
            { text = "九部", comment = "jiu bu" },
            { text = "旧部", comment = "jiu bu" },
            { text = "旧堡", comment = "jiu bu" },
            { text = "久不", comment = "jiu bu" },
        },
        ["jiu di"] = {
            { text = "就地", comment = "jiu di" },
            { text = "就低", comment = "jiu di" },
            { text = "旧地", comment = "jiu di" },
            { text = "九地", comment = "jiu di" },
            { text = "久帝", comment = "jiu di" },
            { text = "九弟", comment = "jiu di" },
        },
        ["jiu en"] = {
            { text = "救恩", comment = "jiu en" },
            { text = "就嗯", comment = "jiu en" },
            { text = "玖恩", comment = "jiu en" },
        },
        ["jiu fo"] = {
            { text = "九佛", comment = "jiu fo" },
        },
        ["jiu huai"] = {
            { text = "就坏", comment = "jiu huai" },
        },
        ["jiu ou"] = {
            { text = "酒瓯", comment = "jiu ou" },
        },
        ["jiu ri"] = {
            { text = "九日", comment = "jiu ri" },
            { text = "旧日", comment = "jiu ri" },
            { text = "久日", comment = "jiu ri" },
        },
        ["ju dai"] = {
            { text = "拒贷", comment = "ju dai" },
            { text = "拒待", comment = "ju dai" },
        },
        ["ju dan"] = {
            { text = "拒单", comment = "ju dan" },
            { text = "巨蛋", comment = "ju dan" },
        },
        ["ju dou"] = {
            { text = "句读", comment = "ju dou" },
            { text = "菊豆", comment = "ju dou" },
            { text = "巨逗", comment = "ju dou" },
            { text = "焗豆", comment = "ju dou" },
        },
        ["ju duan"] = {
            { text = "局端", comment = "ju duan" },
            { text = "锯断", comment = "ju duan" },
            { text = "句段", comment = "ju duan" },
        },
        ["ju duo"] = {
            { text = "居多", comment = "ju duo" },
            { text = "巨多", comment = "ju duo" },
            { text = "橘朵", comment = "ju duo" },
        },
        ["ju e"] = {
            { text = "巨额", comment = "ju e" },
            { text = "巨鳄", comment = "ju e" },
            { text = "剧哦", comment = "ju e" },
            { text = "沮遏", comment = "ju e" },
            { text = "据俄", comment = "ju e" },
        },
        ["ju nan"] = {
            { text = "莒南", comment = "ju nan" },
        },
        ["ju nei"] = {
            { text = "局内", comment = "ju nei" },
            { text = "惧内", comment = "ju nei" },
        },
        ["ju ni yu"] = {
            { text = "拘泥于", comment = "ju ni yu" },
        },
        ["ju ti e"] = {
            { text = "具体哦", comment = "ju ti e" },
        },
        ["ju tie"] = {
            { text = "举铁", comment = "ju tie" },
            { text = "聚铁", comment = "ju tie" },
        },
        ["jue"] = {
            { text = "觉", comment = "jue" },
            { text = "绝", comment = "jue" },
            { text = "决", comment = "jue" },
            { text = "倔", comment = "jue" },
            { text = "掘", comment = "jue" },
            { text = "诀", comment = "jue" },
            { text = "爵", comment = "jue" },
            { text = "撅", comment = "jue" },
            { text = "厥", comment = "jue" },
            { text = "珏", comment = "jue" },
            { text = "角", comment = "jue" },
            { text = "嚼", comment = "jue" },
            { text = "噘", comment = "jue" },
            { text = "孓", comment = "jue" },
            { text = "崛", comment = "jue" },
            { text = "蕨", comment = "jue" },
            { text = "玦", comment = "jue" },
            { text = "桷", comment = "jue" },
            { text = "抉", comment = "jue" },
            { text = "蹶", comment = "jue" },
            { text = "攫", comment = "jue" },
            { text = "橛", comment = "jue" },
            { text = "谲", comment = "jue" },
            { text = "镢", comment = "jue" },
            { text = "矍", comment = "jue" },
            { text = "獗", comment = "jue" },
            { text = "爝", comment = "jue" },
            { text = "傕", comment = "jue" },
            { text = "噱", comment = "jue" },
            { text = "劂", comment = "jue" },
            { text = "觖", comment = "jue" },
            { text = "埆", comment = "jue" },
            { text = "矞", comment = "jue" },
            { text = "焆", comment = "jue" },
            { text = "玃", comment = "jue" },
            { text = "砄", comment = "jue" },
            { text = "㵐", comment = "jue" },
            { text = "夬", comment = "jue" },
            { text = "鞒", comment = "jue" },
            { text = "𫔎", comment = "jue" },
            { text = "𫘝", comment = "jue" },
            { text = "𨟠", comment = "jue" },
        },
        ["jue ai"] = {
            { text = "绝爱", comment = "jue ai" },
        },
        ["jue an"] = {
            { text = "决案", comment = "jue an" },
        },
        ["jue bu"] = {
            { text = "绝不", comment = "jue bu" },
            { text = "决不", comment = "jue bu" },
        },
        ["jue wo"] = {
            { text = "绝我", comment = "jue wo" },
        },
        ["jue xu"] = {
            { text = "绝续", comment = "jue xu" },
        },
        ["jun an"] = {
            { text = "君安", comment = "jun an" },
            { text = "均安", comment = "jun an" },
            { text = "均按", comment = "jun an" },
            { text = "军安", comment = "jun an" },
            { text = "俊安", comment = "jun an" },
            { text = "骏安", comment = "jun an" },
        },
        ["jun di"] = {
            { text = "军地", comment = "jun di" },
            { text = "君地", comment = "jun di" },
            { text = "俊迪", comment = "jun di" },
            { text = "骏迪", comment = "jun di" },
            { text = "骏地", comment = "jun di" },
        },
        ["jun huai"] = {
            { text = "君怀", comment = "jun huai" },
        },
        ["jun ri"] = {
            { text = "俊日", comment = "jun ri" },
        },
        ["jun yin"] = {
            { text = "军印", comment = "jun yin" },
        },
        ["ka ao"] = {
            { text = "卡奥", comment = "ka ao" },
        },
        ["ka ba"] = {
            { text = "卡巴", comment = "ka ba" },
            { text = "卡吧", comment = "ka ba" },
            { text = "咔吧", comment = "ka ba" },
            { text = "喀吧", comment = "ka ba" },
        },
        ["ka bai"] = {
            { text = "卡柏", comment = "ka bai" },
            { text = "卡白", comment = "ka bai" },
        },
        ["ka ban"] = {
            { text = "卡板", comment = "ka ban" },
            { text = "卡班", comment = "ka ban" },
            { text = "卡版", comment = "ka ban" },
        },
        ["ka bei yi"] = {
            { text = "卡倍亿", comment = "ka bei yi" },
        },
        ["ka bi bu"] = {
            { text = "卡比布", comment = "ka bi bu" },
        },
        ["ka bin"] = {
            { text = "卡宾", comment = "ka bin" },
        },
        ["ka bo en"] = {
            { text = "卡博恩", comment = "ka bo en" },
        },
        ["ka bu"] = {
            { text = "卡不", comment = "ka bu" },
            { text = "卡布", comment = "ka bu" },
            { text = "卡部", comment = "ka bu" },
        },
        ["ka fo"] = {
            { text = "卡佛", comment = "ka fo" },
        },
        ["ka na"] = {
            { text = "卡纳", comment = "ka na" },
            { text = "卡娜", comment = "ka na" },
        },
        ["ka nei"] = {
            { text = "卡内", comment = "ka nei" },
        },
        ["ka niu"] = {
            { text = "卡牛", comment = "ka niu" },
        },
        ["ka nuo"] = {
            { text = "卡诺", comment = "ka nuo" },
        },
        ["ka ou"] = {
            { text = "卡欧", comment = "ka ou" },
        },
        ["ka tai"] = {
            { text = "卡台", comment = "ka tai" },
        },
        ["ka tan"] = {
            { text = "咯痰", comment = "ka tan" },
        },
        ["ka tie"] = {
            { text = "卡贴", comment = "ka tie" },
        },
        ["ka tou"] = {
            { text = "卡头", comment = "ka tou" },
        },
        ["ka tuan"] = {
            { text = "卡团", comment = "ka tuan" },
        },
        ["ka tuo"] = {
            { text = "卡托", comment = "ka tuo" },
        },
        ["ka ya"] = {
            { text = "卡呀", comment = "ka ya" },
            { text = "卡压", comment = "ka ya" },
            { text = "卡雅", comment = "ka ya" },
        },
        ["ka ya e"] = {
            { text = "卡亚俄", comment = "ka ya e" },
        },
        ["ka yan"] = {
            { text = "卡宴", comment = "ka yan" },
            { text = "卡焰", comment = "ka yan" },
        },
        ["ka yao"] = {
            { text = "卡药", comment = "ka yao" },
        },
        ["ka ye"] = {
            { text = "卡爷", comment = "ka ye" },
        },
        ["ka yin"] = {
            { text = "卡因", comment = "ka yin" },
        },
        ["ka you"] = {
            { text = "卡友", comment = "ka you" },
            { text = "卡油", comment = "ka you" },
            { text = "卡游", comment = "ka you" },
        },
        ["kai a"] = {
            { text = "开啊", comment = "kai a" },
        },
        ["kai an"] = {
            { text = "开案", comment = "kai an" },
            { text = "凯安", comment = "kai an" },
            { text = "开安", comment = "kai an" },
        },
        ["kai ao"] = {
            { text = "凯傲", comment = "kai ao" },
            { text = "凯奥", comment = "kai ao" },
        },
        ["kai bu"] = {
            { text = "开不", comment = "kai bu" },
            { text = "开埠", comment = "kai bu" },
        },
        ["kai e"] = {
            { text = "开哦", comment = "kai e" },
        },
        ["kai fo"] = {
            { text = "开佛", comment = "kai fo" },
            { text = "开佛", comment = "kai fo" },
        },
        ["kai huai"] = {
            { text = "开怀", comment = "kai huai" },
        },
        ["kai ou"] = {
            { text = "凯欧", comment = "kai ou" },
        },
        ["kai ri"] = {
            { text = "开日", comment = "kai ri" },
        },
        ["kai yu"] = {
            { text = "开宇", comment = "kai yu" },
            { text = "凯宇", comment = "kai yu" },
            { text = "凯裕", comment = "kai yu" },
            { text = "开域", comment = "kai yu" },
            { text = "开渔", comment = "kai yu" },
            { text = "凯誉", comment = "kai yu" },
            { text = "凯玉", comment = "kai yu" },
        },
        ["kan a"] = {
            { text = "看啊", comment = "kan a" },
        },
        ["kan di"] = {
            { text = "看地", comment = "kan di" },
        },
        ["kan wo"] = {
            { text = "看我", comment = "kan wo" },
            { text = "砍我", comment = "kan wo" },
        },
        ["kan yu"] = {
            { text = "看雨", comment = "kan yu" },
            { text = "堪舆", comment = "kan yu" },
        },
        ["kang ai"] = {
            { text = "抗癌", comment = "kang ai" },
            { text = "康爱", comment = "kang ai" },
            { text = "抗艾", comment = "kang ai" },
            { text = "康艾", comment = "kang ai" },
        },
        ["kang an"] = {
            { text = "康安", comment = "kang an" },
        },
        ["kang bu"] = {
            { text = "抗不", comment = "kang bu" },
        },
        ["kang huai"] = {
            { text = "康淮", comment = "kang huai" },
        },
        ["kang ri"] = {
            { text = "抗日", comment = "kang ri" },
        },
        ["kang wo"] = {
            { text = "抗倭", comment = "kang wo" },
            { text = "康沃", comment = "kang wo" },
            { text = "康我", comment = "kang wo" },
        },
        ["kang xu"] = {
            { text = "康旭", comment = "kang xu" },
        },
        ["kang ye"] = {
            { text = "康业", comment = "kang ye" },
            { text = "康爷", comment = "kang ye" },
            { text = "康烨", comment = "kang ye" },
        },
        ["kao a"] = {
            { text = "考啊", comment = "kao a" },
        },
        ["kao ai"] = {
            { text = "考艾", comment = "kao ai" },
        },
        ["kao an"] = {
            { text = "靠岸", comment = "kao an" },
        },
        ["kao ben"] = {
            { text = "考本", comment = "kao ben" },
        },
        ["kao di yi"] = {
            { text = "考第一", comment = "kao di yi" },
        },
        ["kao you"] = {
            { text = "靠右", comment = "kao you" },
            { text = "考友", comment = "kao you" },
        },
        ["kao yu"] = {
            { text = "烤鱼", comment = "kao yu" },
            { text = "考语", comment = "kao yu" },
        },
        ["ke bu"] = {
            { text = "可不", comment = "ke bu" },
            { text = "可怖", comment = "ke bu" },
            { text = "可补", comment = "ke bu" },
            { text = "柯布", comment = "ke bu" },
        },
        ["ke huai"] = {
            { text = "磕坏", comment = "ke huai" },
        },
        ["ke nei"] = {
            { text = "课内", comment = "ke nei" },
            { text = "科内", comment = "ke nei" },
        },
        ["ke nen"] = {
            { text = "可嫩", comment = "ke nen" },
        },
        ["ke ou"] = {
            { text = "科欧", comment = "ke ou" },
            { text = "可欧", comment = "ke ou" },
        },
        ["ke ri"] = {
            { text = "克日", comment = "ke ri" },
            { text = "科日", comment = "ke ri" },
        },
        ["ke ta"] = {
            { text = "可他", comment = "ke ta" },
            { text = "可她", comment = "ke ta" },
            { text = "可它", comment = "ke ta" },
        },
        ["ke tou"] = {
            { text = "磕头", comment = "ke tou" },
            { text = "可投", comment = "ke tou" },
            { text = "科投", comment = "ke tou" },
            { text = "客投", comment = "ke tou" },
            { text = "课头", comment = "ke tou" },
        },
        ["ke tuo"] = {
            { text = "科拓", comment = "ke tuo" },
            { text = "可拓", comment = "ke tuo" },
        },
        ["ken di"] = {
            { text = "肯迪", comment = "ken di" },
            { text = "肯帝", comment = "ken di" },
            { text = "垦地", comment = "ken di" },
        },
        ["ken en"] = {
            { text = "肯恩", comment = "ken en" },
        },
        ["keng a"] = {
            { text = "坑啊", comment = "keng a" },
        },
        ["keng bu"] = {
            { text = "坑不", comment = "keng bu" },
        },
        ["keng wo"] = {
            { text = "坑我", comment = "keng wo" },
        },
        ["kong bu"] = {
            { text = "恐怖", comment = "kong bu" },
            { text = "空不", comment = "kong bu" },
        },
        ["kong huai"] = {
            { text = "空怀", comment = "kong huai" },
        },
        ["kong ou"] = {
            { text = "控偶", comment = "kong ou" },
        },
        ["kong ri"] = {
            { text = "空日", comment = "kong ri" },
        },
        ["ku bai"] = {
            { text = "库柏", comment = "ku bai" },
        },
        ["ku bie"] = {
            { text = "库别", comment = "ku bie" },
        },
        ["ku nei"] = {
            { text = "库内", comment = "ku nei" },
        },
        ["ku niu"] = {
            { text = "酷牛", comment = "ku niu" },
        },
        ["ku ya"] = {
            { text = "苦呀", comment = "ku ya" },
            { text = "酷雅", comment = "ku ya" },
        },
        ["ku yan"] = {
            { text = "哭咽", comment = "ku yan" },
        },
        ["ku you"] = {
            { text = "酷游", comment = "ku you" },
            { text = "酷友", comment = "ku you" },
            { text = "库有", comment = "ku you" },
        },
        ["ku yuan"] = {
            { text = "库员", comment = "ku yuan" },
        },
        ["kua ni ne"] = {
            { text = "夸你呢", comment = "kua ni ne" },
        },
        ["kua tai"] = {
            { text = "垮台", comment = "kua tai" },
        },
        ["kua yuan"] = {
            { text = "跨院", comment = "kua yuan" },
        },
        ["kua yue"] = {
            { text = "跨越", comment = "kua yue" },
            { text = "跨月", comment = "kua yue" },
        },
        ["kuai ne"] = {
            { text = "快呢", comment = "kuai ne" },
        },
        ["kuai xu"] = {
            { text = "快婿", comment = "kuai xu" },
        },
        ["kuan yue"] = {
            { text = "宽约", comment = "kuan yue" },
        },
        ["kuang ai"] = {
            { text = "狂爱", comment = "kuang ai" },
        },
        ["kui a"] = {
            { text = "亏啊", comment = "kui a" },
        },
        ["kui an"] = {
            { text = "魁岸", comment = "kui an" },
        },
        ["kui bu"] = {
            { text = "跬步", comment = "kui bu" },
        },
        ["kui xu"] = {
            { text = "亏虚", comment = "kui xu" },
        },
        ["kun di"] = {
            { text = "坤弟", comment = "kun di" },
        },
        ["kun yu"] = {
            { text = "昆玉", comment = "kun yu" },
            { text = "坤宇", comment = "kun yu" },
            { text = "昆宇", comment = "kun yu" },
            { text = "坤钰", comment = "kun yu" },
        },
        ["kuo ai"] = {
            { text = "阔爱", comment = "kuo ai" },
        },
        ["kuo ye"] = {
            { text = "阔叶", comment = "kuo ye" },
            { text = "阔野", comment = "kuo ye" },
        },
        ["la ba"] = {
            { text = "喇叭", comment = "la ba" },
            { text = "拉吧", comment = "la ba" },
            { text = "腊八", comment = "la ba" },
            { text = "拉拔", comment = "la ba" },
            { text = "拉巴", comment = "la ba" },
        },
        ["la ba yi"] = {
            { text = "拉拔仪", comment = "la ba yi" },
        },
        ["la bai"] = {
            { text = "拉白", comment = "la bai" },
            { text = "蜡白", comment = "la bai" },
        },
        ["la ban"] = {
            { text = "拉板", comment = "la ban" },
            { text = "拉班", comment = "la ban" },
            { text = "蜡板", comment = "la ban" },
            { text = "蜡版", comment = "la ban" },
        },
        ["la bang"] = {
            { text = "拉邦", comment = "la bang" },
            { text = "辣棒", comment = "la bang" },
            { text = "拉帮", comment = "la bang" },
        },
        ["la bao"] = {
            { text = "拉爆", comment = "la bao" },
            { text = "辣堡", comment = "la bao" },
            { text = "拉堡", comment = "la bao" },
            { text = "拉包", comment = "la bao" },
            { text = "拉宝", comment = "la bao" },
            { text = "落堡", comment = "la bao" },
        },
        ["la bei"] = {
            { text = "拉贝", comment = "la bei" },
        },
        ["la bin"] = {
            { text = "拉宾", comment = "la bin" },
        },
        ["la huai"] = {
            { text = "拉坏", comment = "la huai" },
        },
        ["la na"] = {
            { text = "拉娜", comment = "la na" },
        },
        ["la niu"] = {
            { text = "拉牛", comment = "la niu" },
        },
        ["la nuo"] = {
            { text = "拉诺", comment = "la nuo" },
        },
        ["la ri"] = {
            { text = "腊日", comment = "la ri" },
        },
        ["la ta"] = {
            { text = "邋遢", comment = "la ta" },
            { text = "拉他", comment = "la ta" },
            { text = "拉她", comment = "la ta" },
            { text = "拉塔", comment = "la ta" },
        },
        ["la ta en"] = {
            { text = "拉塔恩", comment = "la ta en" },
        },
        ["la tao"] = {
            { text = "拉套", comment = "la tao" },
        },
        ["la te ang"] = {
            { text = "拉特昂", comment = "la te ang" },
        },
        ["la tie"] = {
            { text = "拉铁", comment = "la tie" },
        },
        ["la tuo"] = {
            { text = "拉脱", comment = "la tuo" },
            { text = "拉托", comment = "la tuo" },
            { text = "蜡拖", comment = "la tuo" },
        },
        ["la ya"] = {
            { text = "拉亚", comment = "la ya" },
            { text = "腊鸭", comment = "la ya" },
            { text = "拉雅", comment = "la ya" },
            { text = "拉压", comment = "la ya" },
        },
        ["la yan"] = {
            { text = "辣眼", comment = "la yan" },
            { text = "拉延", comment = "la yan" },
        },
        ["la yang"] = {
            { text = "拉秧", comment = "la yang" },
        },
        ["la ye"] = {
            { text = "拉野", comment = "la ye" },
            { text = "拉页", comment = "la ye" },
        },
        ["la you"] = {
            { text = "辣油", comment = "la you" },
            { text = "蜡油", comment = "la you" },
            { text = "拉油", comment = "la you" },
        },
        ["la yuan"] = {
            { text = "拉远", comment = "la yuan" },
            { text = "拉远", comment = "la yuan" },
        },
        ["la yue"] = {
            { text = "腊月", comment = "la yue" },
        },
        ["lai a"] = {
            { text = "来啊", comment = "lai a" },
        },
        ["lai an"] = {
            { text = "来安", comment = "lai an" },
            { text = "莱安", comment = "lai an" },
        },
        ["lai ang"] = {
            { text = "莱昂", comment = "lai ang" },
        },
        ["lai bu"] = {
            { text = "来不", comment = "lai bu" },
            { text = "来补", comment = "lai bu" },
            { text = "来布", comment = "lai bu" },
            { text = "赖部", comment = "lai bu" },
        },
        ["lai e"] = {
            { text = "来哦", comment = "lai e" },
        },
        ["lai ne"] = {
            { text = "来呢", comment = "lai ne" },
        },
        ["lai ou"] = {
            { text = "莱欧", comment = "lai ou" },
            { text = "莱欧", comment = "lai ou" },
        },
        ["lai xu"] = {
            { text = "来旭", comment = "lai xu" },
        },
        ["lan a"] = {
            { text = "懒啊", comment = "lan a" },
        },
        ["lan bu"] = {
            { text = "蓝布", comment = "lan bu" },
        },
        ["lan ou"] = {
            { text = "蓝鸥", comment = "lan ou" },
            { text = "兰欧", comment = "lan ou" },
        },
        ["lan wo"] = {
            { text = "拦我", comment = "lan wo" },
            { text = "兰沃", comment = "lan wo" },
        },
        ["lan xi niu"] = {
            { text = "蓝犀牛", comment = "lan xi niu" },
        },
        ["lan xin yu"] = {
            { text = "蓝心羽", comment = "lan xin yu" },
        },
        ["lan yu"] = {
            { text = "蓝雨", comment = "lan yu" },
            { text = "蓝宇", comment = "lan yu" },
            { text = "蓝玉", comment = "lan yu" },
            { text = "兰宇", comment = "lan yu" },
            { text = "蓝羽", comment = "lan yu" },
            { text = "蓝鱼", comment = "lan yu" },
            { text = "兰玉", comment = "lan yu" },
            { text = "兰渝", comment = "lan yu" },
            { text = "岚语", comment = "lan yu" },
            { text = "兰雨", comment = "lan yu" },
            { text = "蓝域", comment = "lan yu" },
        },
        ["lang a"] = {
            { text = "浪啊", comment = "lang a" },
        },
        ["lang ao"] = {
            { text = "朗奥", comment = "lang ao" },
        },
        ["lang dang"] = {
            { text = "浪荡", comment = "lang dang" },
            { text = "郎当", comment = "lang dang" },
            { text = "莨菪", comment = "lang dang" },
            { text = "啷当", comment = "lang dang" },
            { text = "锒铛", comment = "lang dang" },
        },
        ["lang fen"] = {
            { text = "郎芬", comment = "lang fen" },
        },
        ["lang wo"] = {
            { text = "狼窝", comment = "lang wo" },
            { text = "朗沃", comment = "lang wo" },
        },
        ["lang ye"] = {
            { text = "狼爷", comment = "lang ye" },
        },
        ["lao a"] = {
            { text = "老啊", comment = "lao a" },
        },
        ["lao a yi"] = {
            { text = "老阿姨", comment = "lao a yi" },
        },
        ["lao ai"] = {
            { text = "老爱", comment = "lao ai" },
            { text = "嫪毐", comment = "lao ai" },
            { text = "老艾", comment = "lao ai" },
        },
        ["lao an"] = {
            { text = "老安", comment = "lao an" },
            { text = "劳安", comment = "lao an" },
            { text = "酪胺", comment = "lao an" },
        },
        ["lao ang"] = {
            { text = "老昂", comment = "lao ang" },
        },
        ["lao ao"] = {
            { text = "老媪", comment = "lao ao" },
            { text = "老奥", comment = "lao ao" },
        },
        ["lao bu"] = {
            { text = "老布", comment = "lao bu" },
            { text = "老卜", comment = "lao bu" },
            { text = "劳布", comment = "lao bu" },
            { text = "老步", comment = "lao bu" },
            { text = "劳步", comment = "lao bu" },
        },
        ["lao di"] = {
            { text = "老弟", comment = "lao di" },
            { text = "老底", comment = "lao di" },
            { text = "牢底", comment = "lao di" },
            { text = "老迪", comment = "lao di" },
            { text = "老狄", comment = "lao di" },
        },
        ["lao fo"] = {
            { text = "老佛", comment = "lao fo" },
        },
        ["lao huai"] = {
            { text = "老怀", comment = "lao huai" },
        },
        ["lao ou"] = {
            { text = "老欧", comment = "lao ou" },
        },
        ["lao ri"] = {
            { text = "老日", comment = "lao ri" },
        },
        ["lao yu"] = {
            { text = "老于", comment = "lao yu" },
            { text = "老余", comment = "lao yu" },
            { text = "捞鱼", comment = "lao yu" },
            { text = "牢狱", comment = "lao yu" },
            { text = "老俞", comment = "lao yu" },
            { text = "老鱼", comment = "lao yu" },
            { text = "老妪", comment = "lao yu" },
            { text = "老喻", comment = "lao yu" },
            { text = "老虞", comment = "lao yu" },
            { text = "老玉", comment = "lao yu" },
            { text = "老雨", comment = "lao yu" },
        },
        ["le di"] = {
            { text = "乐迪", comment = "le di" },
            { text = "乐递", comment = "le di" },
            { text = "了第", comment = "le di" },
        },
        ["le ei"] = {
            { text = "了诶", comment = "le ei" },
        },
        ["le ta"] = {
            { text = "了他", comment = "le ta" },
            { text = "了她", comment = "le ta" },
            { text = "了它", comment = "le ta" },
        },
        ["le tai"] = {
            { text = "勒泰", comment = "le tai" },
            { text = "乐泰", comment = "le tai" },
        },
        ["le tao"] = {
            { text = "乐淘", comment = "le tao" },
            { text = "乐涛", comment = "le tao" },
            { text = "乐桃", comment = "le tao" },
        },
        ["le tie"] = {
            { text = "乐铁", comment = "le tie" },
        },
        ["le tou"] = {
            { text = "乐透", comment = "le tou" },
            { text = "乐投", comment = "le tou" },
            { text = "了头", comment = "le tou" },
        },
        ["le ya"] = {
            { text = "了呀", comment = "le ya" },
            { text = "乐雅", comment = "le ya" },
        },
        ["le yan"] = {
            { text = "乐言", comment = "le yan" },
            { text = "乐颜", comment = "le yan" },
            { text = "乐妍", comment = "le yan" },
            { text = "乐嫣", comment = "le yan" },
            { text = "乐研", comment = "le yan" },
            { text = "肋眼", comment = "le yan" },
        },
        ["le yao"] = {
            { text = "乐瑶", comment = "le yao" },
            { text = "了要", comment = "le yao" },
        },
        ["le ye"] = {
            { text = "乐业", comment = "le ye" },
            { text = "了耶", comment = "le ye" },
            { text = "乐爷", comment = "le ye" },
            { text = "了也", comment = "le ye" },
            { text = "乐叶", comment = "le ye" },
        },
        ["le yin"] = {
            { text = "乐印", comment = "le yin" },
        },
        ["le yo"] = {
            { text = "了哟", comment = "le yo" },
        },
        ["le you"] = {
            { text = "乐游", comment = "le you" },
            { text = "乐友", comment = "le you" },
            { text = "了又", comment = "le you" },
            { text = "乐优", comment = "le you" },
            { text = "乐悠", comment = "le you" },
            { text = "了有", comment = "le you" },
        },
        ["le yuan"] = {
            { text = "乐园", comment = "le yuan" },
            { text = "乐源", comment = "le yuan" },
            { text = "乐苑", comment = "le yuan" },
            { text = "乐元", comment = "le yuan" },
            { text = "乐园", comment = "le yuan" },
            { text = "乐源", comment = "le yuan" },
            { text = "乐苑", comment = "le yuan" },
            { text = "乐元", comment = "le yuan" },
        },
        ["le yue"] = {
            { text = "了约", comment = "le yue" },
            { text = "乐悦", comment = "le yue" },
        },
        ["lei a"] = {
            { text = "累啊", comment = "lei a" },
        },
        ["lei an"] = {
            { text = "雷安", comment = "lei an" },
            { text = "类案", comment = "lei an" },
        },
        ["lei ao"] = {
            { text = "雷奥", comment = "lei ao" },
            { text = "蕾奥", comment = "lei ao" },
        },
        ["lei bu"] = {
            { text = "累不", comment = "lei bu" },
            { text = "肋部", comment = "lei bu" },
        },
        ["lei bu si"] = {
            { text = "累不死", comment = "lei bu si" },
            { text = "雷布斯", comment = "lei bu si" },
        },
        ["lei e"] = {
            { text = "累哦", comment = "lei e" },
            { text = "泪厄", comment = "lei e" },
        },
        ["lei ji e"] = {
            { text = "累计额", comment = "lei ji e" },
        },
        ["lei jie"] = {
            { text = "蕾姐", comment = "lei jie" },
            { text = "雷姐", comment = "lei jie" },
            { text = "雷杰", comment = "lei jie" },
            { text = "雷劫", comment = "lei jie" },
            { text = "罍街", comment = "lei jie" },
            { text = "磊姐", comment = "lei jie" },
            { text = "雷洁", comment = "lei jie" },
            { text = "雷捷", comment = "lei jie" },
            { text = "磊杰", comment = "lei jie" },
        },
        ["lei ne"] = {
            { text = "累呢", comment = "lei ne" },
        },
        ["lei o"] = {
            { text = "累哦", comment = "lei o" },
        },
        ["lei ou"] = {
            { text = "雷欧", comment = "lei ou" },
            { text = "雷欧", comment = "lei ou" },
        },
        ["lei ou si"] = {
            { text = "雷欧斯", comment = "lei ou si" },
        },
        ["lei xu"] = {
            { text = "雷旭", comment = "lei xu" },
        },
        ["lei yu"] = {
            { text = "雷雨", comment = "lei yu" },
            { text = "雷宇", comment = "lei yu" },
            { text = "雷羽", comment = "lei yu" },
            { text = "雷鱼", comment = "lei yu" },
            { text = "泪雨", comment = "lei yu" },
            { text = "雷喻", comment = "lei yu" },
        },
        ["leng a"] = {
            { text = "冷啊", comment = "leng a" },
        },
        ["leng ai"] = {
            { text = "冷爱", comment = "leng ai" },
        },
        ["leng ao"] = {
            { text = "冷傲", comment = "leng ao" },
        },
        ["leng bu"] = {
            { text = "冷不", comment = "leng bu" },
            { text = "冷补", comment = "leng bu" },
            { text = "冷布", comment = "leng bu" },
        },
        ["leng ye"] = {
            { text = "冷夜", comment = "leng ye" },
        },
        ["li ao"] = {
            { text = "李敖", comment = "li ao" },
            { text = "里奥", comment = "li ao" },
            { text = "利奥", comment = "li ao" },
            { text = "李奥", comment = "li ao" },
            { text = "李傲", comment = "li ao" },
            { text = "李澳", comment = "li ao" },
            { text = "丽岙", comment = "li ao" },
            { text = "利澳", comment = "li ao" },
        },
        ["li bu"] = {
            { text = "里布", comment = "li bu" },
            { text = "李部", comment = "li bu" },
            { text = "励步", comment = "li bu" },
            { text = "礼部", comment = "li bu" },
            { text = "吏部", comment = "li bu" },
            { text = "力不", comment = "li bu" },
            { text = "黎埠", comment = "li bu" },
            { text = "李埠", comment = "li bu" },
            { text = "梨埠", comment = "li bu" },
        },
        ["li dai"] = {
            { text = "历代", comment = "li dai" },
            { text = "礼袋", comment = "li dai" },
            { text = "里袋", comment = "li dai" },
            { text = "李代", comment = "li dai" },
            { text = "立袋", comment = "li dai" },
            { text = "里带", comment = "li dai" },
        },
        ["li dou"] = {
            { text = "里兜", comment = "li dou" },
            { text = "里都", comment = "li dou" },
            { text = "李都", comment = "li dou" },
            { text = "利都", comment = "li dou" },
            { text = "力都", comment = "li dou" },
        },
        ["li fo"] = {
            { text = "礼佛", comment = "li fo" },
        },
        ["li hai bu"] = {
            { text = "厉害不", comment = "li hai bu" },
        },
        ["li hai ou"] = {
            { text = "李海鸥", comment = "li hai ou" },
        },
        ["li huai"] = {
            { text = "李怀", comment = "li huai" },
        },
        ["li jia nan"] = {
            { text = "李佳楠", comment = "li jia nan" },
            { text = "李佳男", comment = "li jia nan" },
        },
        ["li jian an"] = {
            { text = "李建安", comment = "li jian an" },
        },
        ["li nai"] = {
            { text = "力耐", comment = "li nai" },
            { text = "礼奈", comment = "li nai" },
            { text = "里奈", comment = "li nai" },
        },
        ["li nan"] = {
            { text = "李楠", comment = "li nan" },
            { text = "李南", comment = "li nan" },
            { text = "罹难", comment = "li nan" },
            { text = "李男", comment = "li nan" },
            { text = "丽楠", comment = "li nan" },
            { text = "鲤南", comment = "li nan" },
            { text = "醴难", comment = "li nan" },
            { text = "立楠", comment = "li nan" },
            { text = "立男", comment = "li nan" },
        },
        ["li nao"] = {
            { text = "利脑", comment = "li nao" },
        },
        ["li ne"] = {
            { text = "里呢", comment = "li ne" },
            { text = "李讷", comment = "li ne" },
        },
        ["li nie"] = {
            { text = "沴孽", comment = "li nie" },
        },
        ["li nin"] = {
            { text = "离您", comment = "li nin" },
        },
        ["li niu"] = {
            { text = "犁牛", comment = "li niu" },
            { text = "李妞", comment = "li niu" },
        },
        ["li nuan"] = {
            { text = "李暖", comment = "li nuan" },
        },
        ["li nuo"] = {
            { text = "力诺", comment = "li nuo" },
            { text = "李诺", comment = "li nuo" },
            { text = "里诺", comment = "li nuo" },
            { text = "立诺", comment = "li nuo" },
            { text = "利诺", comment = "li nuo" },
            { text = "丽诺", comment = "li nuo" },
        },
        ["li ou"] = {
            { text = "里欧", comment = "li ou" },
            { text = "利欧", comment = "li ou" },
            { text = "李欧", comment = "li ou" },
            { text = "力偶", comment = "li ou" },
        },
        ["li ri"] = {
            { text = "丽日", comment = "li ri" },
            { text = "李日", comment = "li ri" },
        },
        ["li ru bin"] = {
            { text = "李如彬", comment = "li ru bin" },
        },
        ["li ruo yu"] = {
            { text = "李若愚", comment = "li ruo yu" },
        },
        ["li ta"] = {
            { text = "理他", comment = "li ta" },
            { text = "理她", comment = "li ta" },
            { text = "离他", comment = "li ta" },
            { text = "利他", comment = "li ta" },
            { text = "离她", comment = "li ta" },
            { text = "丽塔", comment = "li ta" },
            { text = "立塔", comment = "li ta" },
            { text = "丽拓", comment = "li ta" },
            { text = "里塔", comment = "li ta" },
        },
        ["li tai"] = {
            { text = "利泰", comment = "li tai" },
            { text = "丽台", comment = "li tai" },
            { text = "立泰", comment = "li tai" },
            { text = "力泰", comment = "li tai" },
            { text = "李泰", comment = "li tai" },
            { text = "李台", comment = "li tai" },
            { text = "李太", comment = "li tai" },
            { text = "丽泰", comment = "li tai" },
            { text = "励泰", comment = "li tai" },
        },
        ["li tan"] = {
            { text = "李倓", comment = "li tan" },
            { text = "李坦", comment = "li tan" },
            { text = "李潭", comment = "li tan" },
        },
        ["li tao"] = {
            { text = "李涛", comment = "li tao" },
            { text = "李桃", comment = "li tao" },
            { text = "李韬", comment = "li tao" },
            { text = "立涛", comment = "li tao" },
            { text = "黎涛", comment = "li tao" },
            { text = "李滔", comment = "li tao" },
            { text = "李陶", comment = "li tao" },
            { text = "利涛", comment = "li tao" },
            { text = "丽涛", comment = "li tao" },
        },
        ["li tie"] = {
            { text = "李铁", comment = "li tie" },
            { text = "礼帖", comment = "li tie" },
        },
        ["li tou"] = {
            { text = "里头", comment = "li tou" },
            { text = "李头", comment = "li tou" },
        },
        ["li tuan"] = {
            { text = "离团", comment = "li tuan" },
            { text = "李团", comment = "li tuan" },
        },
        ["li tuo"] = {
            { text = "力拓", comment = "li tuo" },
            { text = "李拓", comment = "li tuo" },
            { text = "黎托", comment = "li tuo" },
            { text = "利拓", comment = "li tuo" },
            { text = "丽拓", comment = "li tuo" },
            { text = "立拓", comment = "li tuo" },
        },
        ["li wai"] = {
            { text = "例外", comment = "li wai" },
            { text = "里外", comment = "li wai" },
        },
        ["li wai li"] = {
            { text = "里外里", comment = "li wai li" },
        },
        ["li wan"] = {
            { text = "荔湾", comment = "li wan" },
            { text = "理完", comment = "li wan" },
            { text = "力丸", comment = "li wan" },
            { text = "李婉", comment = "li wan" },
            { text = "李万", comment = "li wan" },
            { text = "丽湾", comment = "li wan" },
            { text = "李湾", comment = "li wan" },
            { text = "利万", comment = "li wan" },
            { text = "砺脘", comment = "li wan" },
        },
        ["li wan hua"] = {
            { text = "李婉华", comment = "li wan hua" },
        },
        ["li wan lu"] = {
            { text = "荔湾路", comment = "li wan lu" },
        },
        ["li wan qi"] = {
            { text = "李婉琪", comment = "li wan qi" },
        },
        ["li wang"] = {
            { text = "力王", comment = "li wang" },
            { text = "李旺", comment = "li wang" },
            { text = "离网", comment = "li wang" },
            { text = "力旺", comment = "li wang" },
            { text = "立网", comment = "li wang" },
            { text = "李望", comment = "li wang" },
            { text = "立旺", comment = "li wang" },
            { text = "李王", comment = "li wang" },
        },
        ["li wei"] = {
            { text = "李伟", comment = "li wei" },
            { text = "李威", comment = "li wei" },
            { text = "李薇", comment = "li wei" },
            { text = "李维", comment = "li wei" },
            { text = "李卫", comment = "li wei" },
            { text = "李巍", comment = "li wei" },
            { text = "李炜", comment = "li wei" },
            { text = "立伟", comment = "li wei" },
            { text = "李玮", comment = "li wei" },
            { text = "骊威", comment = "li wei" },
            { text = "立威", comment = "li wei" },
            { text = "李微", comment = "li wei" },
            { text = "利伟", comment = "li wei" },
            { text = "李蔚", comment = "li wei" },
            { text = "丽伟", comment = "li wei" },
            { text = "力维", comment = "li wei" },
            { text = "黎伟", comment = "li wei" },
            { text = "李为", comment = "li wei" },
            { text = "力威", comment = "li wei" },
            { text = "立位", comment = "li wei" },
            { text = "李唯", comment = "li wei" },
            { text = "立为", comment = "li wei" },
            { text = "李韦", comment = "li wei" },
            { text = "利威", comment = "li wei" },
            { text = "李魏", comment = "li wei" },
            { text = "力伟", comment = "li wei" },
            { text = "利维", comment = "li wei" },
            { text = "离位", comment = "li wei" },
            { text = "立维", comment = "li wei" },
            { text = "锂威", comment = "li wei" },
            { text = "李未", comment = "li wei" },
            { text = "力为", comment = "li wei" },
            { text = "栗伟", comment = "li wei" },
            { text = "李纬", comment = "li wei" },
            { text = "里维", comment = "li wei" },
            { text = "丽维", comment = "li wei" },
            { text = "立委", comment = "li wei" },
            { text = "礼伟", comment = "li wei" },
            { text = "丽薇", comment = "li wei" },
            { text = "丽微", comment = "li wei" },
            { text = "丽玮", comment = "li wei" },
        },
        ["li wen"] = {
            { text = "李文", comment = "li wen" },
            { text = "李雯", comment = "li wen" },
            { text = "例文", comment = "li wen" },
            { text = "理文", comment = "li wen" },
            { text = "李玟", comment = "li wen" },
            { text = "立文", comment = "li wen" },
            { text = "丽文", comment = "li wen" },
            { text = "丽雯", comment = "li wen" },
            { text = "力文", comment = "li wen" },
            { text = "利文", comment = "li wen" },
            { text = "李稳", comment = "li wen" },
            { text = "黎文", comment = "li wen" },
            { text = "李闻", comment = "li wen" },
            { text = "莉雯", comment = "li wen" },
        },
        ["li wen ze"] = {
            { text = "李文泽", comment = "li wen ze" },
        },
        ["li ya bin"] = {
            { text = "李亚斌", comment = "li ya bin" },
        },
        ["li yao yu"] = {
            { text = "李耀宇", comment = "li yao yu" },
        },
        ["li yu de"] = {
            { text = "李玉德", comment = "li yu de" },
            { text = "李玉德", comment = "li yu de" },
        },
        ["li yue e"] = {
            { text = "李月娥", comment = "li yue e" },
            { text = "李月娥", comment = "li yue e" },
        },
        ["lia ba"] = {
            { text = "俩吧", comment = "lia ba" },
        },
        ["lia bao"] = {
            { text = "俩包", comment = "lia bao" },
        },
        ["lia tou"] = {
            { text = "俩头", comment = "lia tou" },
        },
        ["lian bu"] = {
            { text = "脸部", comment = "lian bu" },
            { text = "帘布", comment = "lian bu" },
            { text = "莲步", comment = "lian bu" },
            { text = "敛步", comment = "lian bu" },
        },
        ["lian ou"] = {
            { text = "莲藕", comment = "lian ou" },
            { text = "联欧", comment = "lian ou" },
        },
        ["liang bu"] = {
            { text = "两部", comment = "liang bu" },
            { text = "两步", comment = "liang bu" },
            { text = "粮补", comment = "liang bu" },
            { text = "亮部", comment = "liang bu" },
            { text = "两补", comment = "liang bu" },
            { text = "梁部", comment = "liang bu" },
        },
        ["liang huai"] = {
            { text = "两淮", comment = "liang huai" },
        },
        ["liang ri"] = {
            { text = "两日", comment = "liang ri" },
        },
        ["liao a"] = {
            { text = "聊啊", comment = "liao a" },
        },
        ["liao ao"] = {
            { text = "廖傲", comment = "liao ao" },
        },
        ["lie ai"] = {
            { text = "猎爱", comment = "lie ai" },
        },
        ["lie bu"] = {
            { text = "猎捕", comment = "lie bu" },
        },
        ["lin ai"] = {
            { text = "鳞癌", comment = "lin ai" },
        },
        ["lin an"] = {
            { text = "临安", comment = "lin an" },
            { text = "林安", comment = "lin an" },
            { text = "磷铵", comment = "lin an" },
        },
        ["lin ao"] = {
            { text = "林奥", comment = "lin ao" },
            { text = "林傲", comment = "lin ao" },
        },
        ["lin bu"] = {
            { text = "林部", comment = "lin bu" },
            { text = "临补", comment = "lin bu" },
        },
        ["lin e"] = {
            { text = "临额", comment = "lin e" },
        },
        ["lin ou"] = {
            { text = "林鸥", comment = "lin ou" },
        },
        ["lin wo"] = {
            { text = "林沃", comment = "lin wo" },
            { text = "临沃", comment = "lin wo" },
        },
        ["lin xu"] = {
            { text = "林旭", comment = "lin xu" },
            { text = "林圩", comment = "lin xu" },
        },
        ["lin ye"] = {
            { text = "林业", comment = "lin ye" },
            { text = "林烨", comment = "lin ye" },
            { text = "林叶", comment = "lin ye" },
            { text = "林野", comment = "lin ye" },
            { text = "林晔", comment = "lin ye" },
            { text = "临也", comment = "lin ye" },
        },
        ["lin yu"] = {
            { text = "淋雨", comment = "lin yu" },
            { text = "淋浴", comment = "lin yu" },
            { text = "林语", comment = "lin yu" },
            { text = "林宇", comment = "lin yu" },
            { text = "邻域", comment = "lin yu" },
            { text = "林玉", comment = "lin yu" },
            { text = "林雨", comment = "lin yu" },
            { text = "林瑜", comment = "lin yu" },
            { text = "林羽", comment = "lin yu" },
            { text = "林煜", comment = "lin yu" },
            { text = "林钰", comment = "lin yu" },
            { text = "霖雨", comment = "lin yu" },
            { text = "林郁", comment = "lin yu" },
            { text = "淋语", comment = "lin yu" },
            { text = "林昱", comment = "lin yu" },
            { text = "林禹", comment = "lin yu" },
            { text = "林菀", comment = "lin yu" },
            { text = "琳玉", comment = "lin yu" },
            { text = "淋雨", comment = "lin yu" },
            { text = "淋浴", comment = "lin yu" },
            { text = "林语", comment = "lin yu" },
            { text = "林宇", comment = "lin yu" },
            { text = "邻域", comment = "lin yu" },
            { text = "林玉", comment = "lin yu" },
            { text = "林雨", comment = "lin yu" },
            { text = "林瑜", comment = "lin yu" },
            { text = "林羽", comment = "lin yu" },
            { text = "林煜", comment = "lin yu" },
            { text = "林钰", comment = "lin yu" },
            { text = "霖雨", comment = "lin yu" },
            { text = "林郁", comment = "lin yu" },
            { text = "淋语", comment = "lin yu" },
            { text = "林昱", comment = "lin yu" },
            { text = "林禹", comment = "lin yu" },
            { text = "林菀", comment = "lin yu" },
            { text = "琳玉", comment = "lin yu" },
        },
        ["ling a"] = {
            { text = "领啊", comment = "ling a" },
        },
        ["ling ai"] = {
            { text = "令爱", comment = "ling ai" },
            { text = "令嫒", comment = "ling ai" },
        },
        ["ling an"] = {
            { text = "另案", comment = "ling an" },
            { text = "灵安", comment = "ling an" },
            { text = "凌安", comment = "ling an" },
        },
        ["ling ao"] = {
            { text = "凌傲", comment = "ling ao" },
            { text = "凌奥", comment = "ling ao" },
        },
        ["ling bu"] = {
            { text = "领不", comment = "ling bu" },
        },
        ["ling ji dan"] = {
            { text = "领鸡蛋", comment = "ling ji dan" },
        },
        ["ling jie an"] = {
            { text = "零结案", comment = "ling jie an" },
        },
        ["ling qu e"] = {
            { text = "领取额", comment = "ling qu e" },
        },
        ["ling que"] = {
            { text = "灵鹊", comment = "ling que" },
        },
        ["ling wo"] = {
            { text = "令我", comment = "ling wo" },
            { text = "领我", comment = "ling wo" },
            { text = "领窝", comment = "ling wo" },
        },
        ["ling xu"] = {
            { text = "灵虚", comment = "ling xu" },
            { text = "零序", comment = "ling xu" },
            { text = "凌旭", comment = "ling xu" },
            { text = "灵墟", comment = "ling xu" },
            { text = "凌虚", comment = "ling xu" },
        },
        ["ling ye"] = {
            { text = "灵液", comment = "ling ye" },
            { text = "领业", comment = "ling ye" },
            { text = "凌夜", comment = "ling ye" },
        },
        ["ling yu e"] = {
            { text = "零余额", comment = "ling yu e" },
            { text = "零余额", comment = "ling yu e" },
        },
        ["ling yue"] = {
            { text = "灵越", comment = "ling yue" },
            { text = "另约", comment = "ling yue" },
            { text = "菱悦", comment = "ling yue" },
            { text = "凌月", comment = "ling yue" },
            { text = "凌越", comment = "ling yue" },
            { text = "领越", comment = "ling yue" },
            { text = "灵悦", comment = "ling yue" },
            { text = "泠月", comment = "ling yue" },
            { text = "灵越", comment = "ling yue" },
            { text = "另约", comment = "ling yue" },
            { text = "菱悦", comment = "ling yue" },
            { text = "凌月", comment = "ling yue" },
            { text = "凌越", comment = "ling yue" },
            { text = "领越", comment = "ling yue" },
            { text = "灵悦", comment = "ling yue" },
            { text = "泠月", comment = "ling yue" },
        },
        ["liu ai"] = {
            { text = "刘爱", comment = "liu ai" },
            { text = "刘艾", comment = "liu ai" },
        },
        ["liu ai li"] = {
            { text = "刘爱丽", comment = "liu ai li" },
        },
        ["liu an"] = {
            { text = "刘安", comment = "liu an" },
            { text = "柳岸", comment = "liu an" },
            { text = "留案", comment = "liu an" },
            { text = "硫铵", comment = "liu an" },
            { text = "柳桉", comment = "liu an" },
        },
        ["liu an hua"] = {
            { text = "刘安华", comment = "liu an hua" },
            { text = "六安话", comment = "liu an hua" },
        },
        ["liu an lu"] = {
            { text = "六安路", comment = "liu an lu" },
        },
        ["liu an qi"] = {
            { text = "刘安琪", comment = "liu an qi" },
        },
        ["liu ang"] = {
            { text = "刘昂", comment = "liu ang" },
        },
        ["liu bu"] = {
            { text = "六部", comment = "liu bu" },
            { text = "留步", comment = "liu bu" },
            { text = "刘部", comment = "liu bu" },
            { text = "六步", comment = "liu bu" },
            { text = "柳埠", comment = "liu bu" },
            { text = "六不", comment = "liu bu" },
            { text = "流布", comment = "liu bu" },
        },
        ["liu di"] = {
            { text = "留底", comment = "liu di" },
            { text = "留抵", comment = "liu di" },
            { text = "刘迪", comment = "liu di" },
            { text = "六弟", comment = "liu di" },
            { text = "刘娣", comment = "liu di" },
            { text = "柳笛", comment = "liu di" },
            { text = "刘笛", comment = "liu di" },
            { text = "刘頔", comment = "liu di" },
            { text = "刘棣", comment = "liu di" },
        },
        ["liu en"] = {
            { text = "刘恩", comment = "liu en" },
        },
        ["liu en ze"] = {
            { text = "刘恩泽", comment = "liu en ze" },
        },
        ["liu hua wei"] = {
            { text = "刘华伟", comment = "liu hua wei" },
        },
        ["liu huai"] = {
            { text = "刘怀", comment = "liu huai" },
        },
        ["liu jia nan"] = {
            { text = "刘佳楠", comment = "liu jia nan" },
            { text = "刘佳男", comment = "liu jia nan" },
        },
        ["liu jian an"] = {
            { text = "刘建安", comment = "liu jian an" },
        },
        ["liu ou"] = {
            { text = "刘鸥", comment = "liu ou" },
        },
        ["liu ri"] = {
            { text = "六日", comment = "liu ri" },
            { text = "刘日", comment = "liu ri" },
        },
        ["liu ru di"] = {
            { text = "流入地", comment = "liu ru di" },
        },
        ["long huai"] = {
            { text = "龙怀", comment = "long huai" },
        },
        ["long ri"] = {
            { text = "龙日", comment = "long ri" },
        },
        ["lu bai"] = {
            { text = "鲁百", comment = "lu bai" },
        },
        ["lu ban"] = {
            { text = "鲁班", comment = "lu ban" },
            { text = "鹿班", comment = "lu ban" },
            { text = "录班", comment = "lu ban" },
            { text = "露伴", comment = "lu ban" },
        },
        ["lu bang"] = {
            { text = "鲁邦", comment = "lu bang" },
            { text = "鲁棒", comment = "lu bang" },
            { text = "路邦", comment = "lu bang" },
        },
        ["lu bao"] = {
            { text = "路宝", comment = "lu bao" },
            { text = "芦苞", comment = "lu bao" },
            { text = "炉包", comment = "lu bao" },
            { text = "鲁宝", comment = "lu bao" },
            { text = "陆宝", comment = "lu bao" },
            { text = "潞宝", comment = "lu bao" },
            { text = "鹿宝", comment = "lu bao" },
            { text = "露宝", comment = "lu bao" },
            { text = "璐宝", comment = "lu bao" },
            { text = "路豹", comment = "lu bao" },
        },
        ["lu bei"] = {
            { text = "路北", comment = "lu bei" },
            { text = "鲁北", comment = "lu bei" },
        },
        ["lu ben"] = {
            { text = "鲁本", comment = "lu ben" },
        },
        ["lu bi ao"] = {
            { text = "卢比奥", comment = "lu bi ao" },
        },
        ["lu bin"] = {
            { text = "陆斌", comment = "lu bin" },
            { text = "卢斌", comment = "lu bin" },
            { text = "鲁斌", comment = "lu bin" },
            { text = "卢彬", comment = "lu bin" },
            { text = "陆彬", comment = "lu bin" },
            { text = "路斌", comment = "lu bin" },
        },
        ["lu bo"] = {
            { text = "录播", comment = "lu bo" },
            { text = "录波", comment = "lu bo" },
            { text = "卢波", comment = "lu bo" },
            { text = "陆波", comment = "lu bo" },
            { text = "路博", comment = "lu bo" },
            { text = "卢博", comment = "lu bo" },
            { text = "陆博", comment = "lu bo" },
            { text = "鲁波", comment = "lu bo" },
            { text = "鲁博", comment = "lu bo" },
        },
        ["lu bu"] = {
            { text = "卢布", comment = "lu bu" },
            { text = "露布", comment = "lu bu" },
            { text = "陆埠", comment = "lu bu" },
            { text = "禄步", comment = "lu bu" },
            { text = "卢部", comment = "lu bu" },
        },
        ["lu e"] = {
            { text = "卤鹅", comment = "lu e" },
        },
        ["lu nei"] = {
            { text = "颅内", comment = "lu nei" },
            { text = "炉内", comment = "lu nei" },
            { text = "路内", comment = "lu nei" },
        },
        ["lu ou"] = {
            { text = "卤藕", comment = "lu ou" },
        },
        ["lue"] = {
            { text = "略", comment = "lue" },
            { text = "掠", comment = "lue" },
            { text = "锊", comment = "lue" },
            { text = "圙", comment = "lue" },
            { text = "䂮", comment = "lue" },
        },
        ["lun di"] = {
            { text = "论敌", comment = "lun di" },
        },
        ["luo ai"] = {
            { text = "裸爱", comment = "luo ai" },
        },
        ["luo an"] = {
            { text = "罗安", comment = "luo an" },
            { text = "洛安", comment = "luo an" },
        },
        ["luo ang"] = {
            { text = "洛昂", comment = "luo ang" },
        },
        ["luo ao"] = {
            { text = "罗坳", comment = "luo ao" },
        },
        ["luo bu"] = {
            { text = "罗布", comment = "luo bu" },
            { text = "落布", comment = "luo bu" },
            { text = "罗埠", comment = "luo bu" },
            { text = "落堡", comment = "luo bu" },
        },
        ["luo di"] = {
            { text = "落地", comment = "luo di" },
            { text = "罗迪", comment = "luo di" },
            { text = "落第", comment = "luo di" },
            { text = "落底", comment = "luo di" },
            { text = "罗蒂", comment = "luo di" },
            { text = "洛迪", comment = "luo di" },
        },
        ["luo en"] = {
            { text = "罗恩", comment = "luo en" },
            { text = "洛恩", comment = "luo en" },
        },
        ["luo o"] = {
            { text = "咯喔", comment = "luo o" },
        },
        ["luo ou"] = {
            { text = "洛欧", comment = "luo ou" },
        },
        ["luo yao"] = {
            { text = "罗瑶", comment = "luo yao" },
            { text = "罗尧", comment = "luo yao" },
            { text = "洛瑶", comment = "luo yao" },
            { text = "罗耀", comment = "luo yao" },
        },
        ["luo yu"] = {
            { text = "落雨", comment = "luo yu" },
            { text = "罗宇", comment = "luo yu" },
            { text = "罗玉", comment = "luo yu" },
            { text = "落于", comment = "luo yu" },
            { text = "罗雨", comment = "luo yu" },
            { text = "珞瑜", comment = "luo yu" },
            { text = "罗瑜", comment = "luo yu" },
            { text = "落羽", comment = "luo yu" },
            { text = "罗钰", comment = "luo yu" },
            { text = "洛羽", comment = "luo yu" },
            { text = "罗羽", comment = "luo yu" },
            { text = "洛雨", comment = "luo yu" },
        },
        ["lv bu"] = {
            { text = "吕布", comment = "lv bu" },
            { text = "滤布", comment = "lv bu" },
            { text = "绿布", comment = "lv bu" },
            { text = "吕部", comment = "lv bu" },
        },
        ["lv hua an"] = {
            { text = "氯化铵", comment = "lv hua an" },
        },
        ["lv hua bu"] = {
            { text = "绿化部", comment = "lv hua bu" },
        },
        ["lv ou"] = {
            { text = "旅欧", comment = "lv ou" },
        },
        ["lv ran"] = {
            { text = "绿然", comment = "lv ran" },
        },
        ["lv rou"] = {
            { text = "驴肉", comment = "lv rou" },
        },
        ["ma ba"] = {
            { text = "骂吧", comment = "ma ba" },
            { text = "妈爸", comment = "ma ba" },
            { text = "马坝", comment = "ma ba" },
        },
        ["ma bai"] = {
            { text = "马白", comment = "ma bai" },
        },
        ["ma ban"] = {
            { text = "马班", comment = "ma ban" },
        },
        ["ma bang"] = {
            { text = "马帮", comment = "ma bang" },
            { text = "马浜", comment = "ma bang" },
        },
        ["ma bao"] = {
            { text = "妈宝", comment = "ma bao" },
            { text = "马宝", comment = "ma bao" },
            { text = "马保", comment = "ma bao" },
            { text = "麻包", comment = "ma bao" },
            { text = "玛堡", comment = "ma bao" },
            { text = "马堡", comment = "ma bao" },
            { text = "马报", comment = "ma bao" },
        },
        ["ma bei"] = {
            { text = "马背", comment = "ma bei" },
            { text = "马贝", comment = "ma bei" },
            { text = "麻陂", comment = "ma bei" },
        },
        ["ma ben"] = {
            { text = "马奔", comment = "ma ben" },
        },
        ["ma bie"] = {
            { text = "马鳖", comment = "ma bie" },
        },
        ["ma bin"] = {
            { text = "马斌", comment = "ma bin" },
            { text = "马彬", comment = "ma bin" },
            { text = "马宾", comment = "ma bin" },
        },
        ["ma bo"] = {
            { text = "马波", comment = "ma bo" },
            { text = "马博", comment = "ma bo" },
            { text = "马勃", comment = "ma bo" },
        },
        ["ma bo yu"] = {
            { text = "马博宇", comment = "ma bo yu" },
        },
        ["ma di"] = {
            { text = "马蒂", comment = "ma di" },
            { text = "妈滴", comment = "ma di" },
            { text = "马迪", comment = "ma di" },
            { text = "马頔", comment = "ma di" },
            { text = "麻地", comment = "ma di" },
            { text = "马弟", comment = "ma di" },
        },
        ["ma ei"] = {
            { text = "妈诶", comment = "ma ei" },
        },
        ["ma na"] = {
            { text = "马娜", comment = "ma na" },
            { text = "玛娜", comment = "ma na" },
            { text = "玛纳", comment = "ma na" },
        },
        ["ma ne"] = {
            { text = "嘛呢", comment = "ma ne" },
        },
        ["ma nei"] = {
            { text = "马内", comment = "ma nei" },
        },
        ["ma niu"] = {
            { text = "马牛", comment = "ma niu" },
        },
        ["ma nuo"] = {
            { text = "马诺", comment = "ma nuo" },
        },
        ["ma ta"] = {
            { text = "骂他", comment = "ma ta" },
            { text = "骂她", comment = "ma ta" },
            { text = "马踏", comment = "ma ta" },
            { text = "玛塔", comment = "ma ta" },
            { text = "马塔", comment = "ma ta" },
        },
        ["ma tou"] = {
            { text = "码头", comment = "ma tou" },
            { text = "马头", comment = "ma tou" },
            { text = "麻头", comment = "ma tou" },
            { text = "杩头", comment = "ma tou" },
        },
        ["ma tou ying"] = {
            { text = "马头营", comment = "ma tou ying" },
        },
        ["ma tuo"] = {
            { text = "孖拖", comment = "ma tuo" },
        },
        ["ma ya"] = {
            { text = "妈呀", comment = "ma ya" },
            { text = "玛雅", comment = "ma ya" },
            { text = "嘛呀", comment = "ma ya" },
            { text = "麻鸭", comment = "ma ya" },
            { text = "马牙", comment = "ma ya" },
            { text = "马亚", comment = "ma ya" },
            { text = "马鸭", comment = "ma ya" },
            { text = "马娅", comment = "ma ya" },
        },
        ["ma yan"] = {
            { text = "马燕", comment = "ma yan" },
            { text = "马艳", comment = "ma yan" },
            { text = "马眼", comment = "ma yan" },
            { text = "马岩", comment = "ma yan" },
            { text = "马妍", comment = "ma yan" },
            { text = "马彦", comment = "ma yan" },
            { text = "马炎", comment = "ma yan" },
            { text = "马延", comment = "ma yan" },
            { text = "马琰", comment = "ma yan" },
            { text = "马研", comment = "ma yan" },
        },
        ["ma yao"] = {
            { text = "麻药", comment = "ma yao" },
            { text = "马瑶", comment = "ma yao" },
            { text = "马尧", comment = "ma yao" },
            { text = "马耀", comment = "ma yao" },
            { text = "马腰", comment = "ma yao" },
            { text = "马遥", comment = "ma yao" },
        },
        ["ma ye"] = {
            { text = "妈耶", comment = "ma ye" },
            { text = "马也", comment = "ma ye" },
            { text = "麻叶", comment = "ma ye" },
            { text = "马爷", comment = "ma ye" },
            { text = "马野", comment = "ma ye" },
            { text = "马烨", comment = "ma ye" },
            { text = "马叶", comment = "ma ye" },
            { text = "马晔", comment = "ma ye" },
        },
        ["ma yi bu"] = {
            { text = "蚂蚁布", comment = "ma yi bu" },
        },
        ["ma yin"] = {
            { text = "马银", comment = "ma yin" },
            { text = "玛茵", comment = "ma yin" },
            { text = "马印", comment = "ma yin" },
        },
        ["ma yo"] = {
            { text = "妈哟", comment = "ma yo" },
        },
        ["ma you"] = {
            { text = "麻油", comment = "ma you" },
            { text = "马油", comment = "ma you" },
            { text = "麻友", comment = "ma you" },
            { text = "马友", comment = "ma you" },
            { text = "马有", comment = "ma you" },
        },
        ["ma yuan"] = {
            { text = "马原", comment = "ma yuan" },
            { text = "马院", comment = "ma yuan" },
            { text = "麻园", comment = "ma yuan" },
            { text = "马媛", comment = "ma yuan" },
            { text = "马元", comment = "ma yuan" },
            { text = "马源", comment = "ma yuan" },
            { text = "马园", comment = "ma yuan" },
            { text = "马远", comment = "ma yuan" },
            { text = "码元", comment = "ma yuan" },
            { text = "麻圆", comment = "ma yuan" },
            { text = "马援", comment = "ma yuan" },
            { text = "马渊", comment = "ma yuan" },
            { text = "马原", comment = "ma yuan" },
            { text = "马院", comment = "ma yuan" },
            { text = "麻园", comment = "ma yuan" },
            { text = "马媛", comment = "ma yuan" },
            { text = "马元", comment = "ma yuan" },
            { text = "马源", comment = "ma yuan" },
            { text = "马园", comment = "ma yuan" },
            { text = "马远", comment = "ma yuan" },
            { text = "码元", comment = "ma yuan" },
            { text = "麻圆", comment = "ma yuan" },
            { text = "马援", comment = "ma yuan" },
            { text = "马渊", comment = "ma yuan" },
        },
        ["ma yue"] = {
            { text = "马月", comment = "ma yue" },
            { text = "马跃", comment = "ma yue" },
            { text = "马悦", comment = "ma yue" },
            { text = "马越", comment = "ma yue" },
            { text = "马玥", comment = "ma yue" },
            { text = "马岳", comment = "ma yue" },
        },
        ["mai a"] = {
            { text = "买啊", comment = "mai a" },
            { text = "卖啊", comment = "mai a" },
        },
        ["mai an"] = {
            { text = "脉案", comment = "mai an" },
        },
        ["mai ao"] = {
            { text = "麦澳", comment = "mai ao" },
        },
        ["mai bu"] = {
            { text = "卖不", comment = "mai bu" },
            { text = "买不", comment = "mai bu" },
            { text = "迈步", comment = "mai bu" },
            { text = "卖部", comment = "mai bu" },
            { text = "买部", comment = "mai bu" },
        },
        ["mai e"] = {
            { text = "买哦", comment = "mai e" },
        },
        ["mai ne"] = {
            { text = "买呢", comment = "mai ne" },
            { text = "卖呢", comment = "mai ne" },
        },
        ["mai o"] = {
            { text = "买哦", comment = "mai o" },
        },
        ["mai ou"] = {
            { text = "迈欧", comment = "mai ou" },
            { text = "迈欧", comment = "mai ou" },
        },
        ["mai xu"] = {
            { text = "麦序", comment = "mai xu" },
        },
        ["mai you"] = {
            { text = "买有", comment = "mai you" },
            { text = "买油", comment = "mai you" },
            { text = "卖油", comment = "mai you" },
            { text = "麦游", comment = "mai you" },
            { text = "卖友", comment = "mai you" },
        },
        ["mai yu"] = {
            { text = "卖鱼", comment = "mai yu" },
            { text = "买鱼", comment = "mai yu" },
        },
        ["man a"] = {
            { text = "慢啊", comment = "man a" },
        },
        ["man bu"] = {
            { text = "漫步", comment = "man bu" },
            { text = "慢步", comment = "man bu" },
            { text = "满布", comment = "man bu" },
            { text = "满补", comment = "man bu" },
        },
        ["man di"] = {
            { text = "满地", comment = "man di" },
            { text = "蛮低", comment = "man di" },
            { text = "曼迪", comment = "man di" },
            { text = "慢递", comment = "man di" },
            { text = "蔓迪", comment = "man di" },
            { text = "曼蒂", comment = "man di" },
        },
        ["man e"] = {
            { text = "满额", comment = "man e" },
        },
        ["man ou"] = {
            { text = "满欧", comment = "man ou" },
        },
        ["man wo"] = {
            { text = "瞒我", comment = "man wo" },
        },
        ["man yu"] = {
            { text = "鳗鱼", comment = "man yu" },
            { text = "曼玉", comment = "man yu" },
            { text = "满语", comment = "man yu" },
            { text = "漫语", comment = "man yu" },
            { text = "满玉", comment = "man yu" },
            { text = "曼瑜", comment = "man yu" },
        },
        ["mang a"] = {
            { text = "忙啊", comment = "mang a" },
        },
        ["mang bu"] = {
            { text = "忙不", comment = "mang bu" },
            { text = "芒部", comment = "mang bu" },
        },
        ["mang bu ying"] = {
            { text = "忙不赢", comment = "mang bu ying" },
        },
        ["mang wo"] = {
            { text = "忙我", comment = "mang wo" },
        },
        ["mao a"] = {
            { text = "毛啊", comment = "mao a" },
        },
        ["mao ai"] = {
            { text = "毛爱", comment = "mao ai" },
        },
        ["mao an"] = {
            { text = "毛安", comment = "mao an" },
            { text = "茅庵", comment = "mao an" },
            { text = "貌岸", comment = "mao an" },
        },
        ["mao ang"] = {
            { text = "毛昂", comment = "mao ang" },
        },
        ["mao ao"] = {
            { text = "毛傲", comment = "mao ao" },
        },
        ["mao bin"] = {
            { text = "毛斌", comment = "mao bin" },
            { text = "毛彬", comment = "mao bin" },
        },
        ["mao di"] = {
            { text = "锚地", comment = "mao di" },
            { text = "毛弟", comment = "mao di" },
            { text = "毛迪", comment = "mao di" },
            { text = "毛地", comment = "mao di" },
            { text = "茂迪", comment = "mao di" },
        },
        ["mao en"] = {
            { text = "瑁恩", comment = "mao en" },
        },
        ["mao o"] = {
            { text = "毛哦", comment = "mao o" },
        },
        ["mao ye"] = {
            { text = "茂业", comment = "mao ye" },
            { text = "猫爷", comment = "mao ye" },
            { text = "帽业", comment = "mao ye" },
        },
        ["mao yu"] = {
            { text = "冒雨", comment = "mao yu" },
            { text = "毛羽", comment = "mao yu" },
            { text = "毛宇", comment = "mao yu" },
            { text = "猫鱼", comment = "mao yu" },
            { text = "毛玉", comment = "mao yu" },
            { text = "毛芋", comment = "mao yu" },
            { text = "锚鱼", comment = "mao yu" },
            { text = "茂宇", comment = "mao yu" },
            { text = "猫语", comment = "mao yu" },
        },
        ["me ya"] = {
            { text = "么呀", comment = "me ya" },
        },
        ["me ye"] = {
            { text = "么也", comment = "me ye" },
        },
        ["me you"] = {
            { text = "么有", comment = "me you" },
        },
        ["mei a"] = {
            { text = "没啊", comment = "mei a" },
            { text = "妹啊", comment = "mei a" },
            { text = "美啊", comment = "mei a" },
        },
        ["mei bu"] = {
            { text = "每部", comment = "mei bu" },
            { text = "没补", comment = "mei bu" },
            { text = "每步", comment = "mei bu" },
            { text = "眉部", comment = "mei bu" },
            { text = "美步", comment = "mei bu" },
            { text = "美补", comment = "mei bu" },
            { text = "梅埠", comment = "mei bu" },
        },
        ["mei di"] = {
            { text = "没底", comment = "mei di" },
            { text = "没地", comment = "mei di" },
            { text = "美帝", comment = "mei di" },
            { text = "美地", comment = "mei di" },
            { text = "美迪", comment = "mei di" },
            { text = "梅迪", comment = "mei di" },
            { text = "美蒂", comment = "mei di" },
            { text = "美滴", comment = "mei di" },
        },
        ["mei e"] = {
            { text = "没饿", comment = "mei e" },
            { text = "美俄", comment = "mei e" },
            { text = "美娥", comment = "mei e" },
            { text = "美哦", comment = "mei e" },
        },
        ["mei ei"] = {
            { text = "没诶", comment = "mei ei" },
        },
        ["mei huai"] = {
            { text = "没坏", comment = "mei huai" },
            { text = "没怀", comment = "mei huai" },
        },
        ["mei ou"] = {
            { text = "美欧", comment = "mei ou" },
        },
        ["mei ri"] = {
            { text = "每日", comment = "mei ri" },
            { text = "美日", comment = "mei ri" },
        },
        ["mi bu"] = {
            { text = "弥补", comment = "mi bu" },
            { text = "密布", comment = "mi bu" },
        },
        ["mi da"] = {
            { text = "米达", comment = "mi da" },
            { text = "咪哒", comment = "mi da" },
            { text = "米大", comment = "mi da" },
        },
        ["mi die"] = {
            { text = "迷迭", comment = "mi die" },
            { text = "迷蝶", comment = "mi die" },
        },
        ["mi nan"] = {
            { text = "米楠", comment = "mi nan" },
            { text = "米南", comment = "mi nan" },
        },
        ["mi nei"] = {
            { text = "米内", comment = "mi nei" },
        },
        ["mi niu"] = {
            { text = "蜜妞", comment = "mi niu" },
        },
        ["mi ou"] = {
            { text = "米欧", comment = "mi ou" },
        },
        ["mi tai"] = {
            { text = "米台", comment = "mi tai" },
        },
        ["mi tan"] = {
            { text = "密探", comment = "mi tan" },
            { text = "密谈", comment = "mi tan" },
        },
        ["mi tao"] = {
            { text = "蜜桃", comment = "mi tao" },
            { text = "密逃", comment = "mi tao" },
            { text = "米桃", comment = "mi tao" },
            { text = "米涛", comment = "mi tao" },
            { text = "米淘", comment = "mi tao" },
            { text = "蜜淘", comment = "mi tao" },
        },
        ["mi te"] = {
            { text = "米特", comment = "mi te" },
        },
        ["mi tie"] = {
            { text = "秘贴", comment = "mi tie" },
            { text = "米贴", comment = "mi tie" },
        },
        ["mi tou"] = {
            { text = "咪头", comment = "mi tou" },
            { text = "密头", comment = "mi tou" },
        },
        ["mi tuan"] = {
            { text = "谜团", comment = "mi tuan" },
            { text = "米团", comment = "mi tuan" },
        },
        ["mian bu"] = {
            { text = "面部", comment = "mian bu" },
            { text = "棉布", comment = "mian bu" },
            { text = "面布", comment = "mian bu" },
            { text = "面补", comment = "mian bu" },
        },
        ["mian ou"] = {
            { text = "面藕", comment = "mian ou" },
        },
        ["mie a"] = {
            { text = "咩啊", comment = "mie a" },
        },
        ["mie ye"] = {
            { text = "乜嘢", comment = "mie ye" },
        },
        ["min an"] = {
            { text = "民安", comment = "min an" },
            { text = "敏安", comment = "min an" },
        },
        ["min di"] = {
            { text = "敏迪", comment = "min di" },
        },
        ["min yu"] = {
            { text = "珉宇", comment = "min yu" },
            { text = "闽语", comment = "min yu" },
            { text = "民宇", comment = "min yu" },
            { text = "鳘鱼", comment = "min yu" },
            { text = "敏瑜", comment = "min yu" },
        },
        ["ming ai"] = {
            { text = "明爱", comment = "ming ai" },
        },
        ["ming an"] = {
            { text = "明暗", comment = "ming an" },
            { text = "命案", comment = "ming an" },
            { text = "明安", comment = "ming an" },
            { text = "铭安", comment = "ming an" },
            { text = "冥暗", comment = "ming an" },
        },
        ["ming ao"] = {
            { text = "明奥", comment = "ming ao" },
        },
        ["ming bu"] = {
            { text = "名捕", comment = "ming bu" },
            { text = "明步", comment = "ming bu" },
        },
        ["ming e"] = {
            { text = "名额", comment = "ming e" },
        },
        ["ming ou"] = {
            { text = "名欧", comment = "ming ou" },
            { text = "铭欧", comment = "ming ou" },
        },
        ["ming xu"] = {
            { text = "明旭", comment = "ming xu" },
            { text = "铭旭", comment = "ming xu" },
        },
        ["ming ye"] = {
            { text = "明夜", comment = "ming ye" },
            { text = "明业", comment = "ming ye" },
            { text = "铭业", comment = "ming ye" },
            { text = "明烨", comment = "ming ye" },
            { text = "冥夜", comment = "ming ye" },
            { text = "明爷", comment = "ming ye" },
            { text = "明叶", comment = "ming ye" },
        },
        ["mo bu"] = {
            { text = "莫不", comment = "mo bu" },
            { text = "膜布", comment = "mo bu" },
        },
        ["mo hu yin"] = {
            { text = "模糊音", comment = "mo hu yin" },
        },
        ["mo huai"] = {
            { text = "磨坏", comment = "mo huai" },
        },
        ["mo hui yu"] = {
            { text = "摸会鱼", comment = "mo hui yu" },
        },
        ["mo ou"] = {
            { text = "魔偶", comment = "mo ou" },
        },
        ["mo ri"] = {
            { text = "末日", comment = "mo ri" },
        },
        ["mo wai"] = {
            { text = "膜外", comment = "mo wai" },
        },
        ["mo wei"] = {
            { text = "末尾", comment = "mo wei" },
            { text = "末位", comment = "mo wei" },
            { text = "莫伟", comment = "mo wei" },
            { text = "魔卫", comment = "mo wei" },
        },
        ["mou ai"] = {
            { text = "谋爱", comment = "mou ai" },
        },
        ["mou di"] = {
            { text = "某地", comment = "mou di" },
        },
        ["mu bu"] = {
            { text = "幕布", comment = "mu bu" },
        },
        ["mu ou"] = {
            { text = "木偶", comment = "mu ou" },
        },
        ["na bai"] = {
            { text = "纳百", comment = "na bai" },
        },
        ["na ban"] = {
            { text = "那版", comment = "na ban" },
            { text = "那般", comment = "na ban" },
            { text = "那班", comment = "na ban" },
            { text = "哪版", comment = "na ban" },
            { text = "哪班", comment = "na ban" },
            { text = "那板", comment = "na ban" },
            { text = "拿办", comment = "na ban" },
        },
        ["na bie"] = {
            { text = "那别", comment = "na bie" },
        },
        ["na na"] = {
            { text = "娜娜", comment = "na na" },
            { text = "哪哪", comment = "na na" },
            { text = "拿拿", comment = "na na" },
            { text = "那那", comment = "na na" },
            { text = "呐呐", comment = "na na" },
            { text = "纳纳", comment = "na na" },
        },
        ["na ni ne"] = {
            { text = "那你呢", comment = "na ni ne" },
        },
        ["na nie"] = {
            { text = "拿捏", comment = "na nie" },
        },
        ["na nin"] = {
            { text = "那您", comment = "na nin" },
        },
        ["na niu"] = {
            { text = "那妞", comment = "na niu" },
        },
        ["na nuo"] = {
            { text = "纳诺", comment = "na nuo" },
            { text = "娜诺", comment = "na nuo" },
            { text = "那诺", comment = "na nuo" },
        },
        ["na ya"] = {
            { text = "哪呀", comment = "na ya" },
            { text = "拿呀", comment = "na ya" },
            { text = "纳雅", comment = "na ya" },
        },
        ["na yan"] = {
            { text = "钠盐", comment = "na yan" },
            { text = "拿烟", comment = "na yan" },
            { text = "那岩", comment = "na yan" },
        },
        ["na yao"] = {
            { text = "那要", comment = "na yao" },
            { text = "拿药", comment = "na yao" },
        },
        ["na yi bu"] = {
            { text = "哪一步", comment = "na yi bu" },
            { text = "那一步", comment = "na yi bu" },
            { text = "哪一部", comment = "na yi bu" },
        },
        ["na yin"] = {
            { text = "纳音", comment = "na yin" },
            { text = "捺印", comment = "na yin" },
        },
        ["na you"] = {
            { text = "哪有", comment = "na you" },
            { text = "那有", comment = "na you" },
            { text = "那又", comment = "na you" },
        },
        ["na yuan"] = {
            { text = "纳元", comment = "na yuan" },
            { text = "纳源", comment = "na yuan" },
            { text = "纳元", comment = "na yuan" },
            { text = "纳源", comment = "na yuan" },
        },
        ["na yue"] = {
            { text = "那月", comment = "na yue" },
            { text = "哪月", comment = "na yue" },
            { text = "那约", comment = "na yue" },
        },
        ["nai a"] = {
            { text = "奶啊", comment = "nai a" },
        },
        ["nai an"] = {
            { text = "萘胺", comment = "nai an" },
        },
        ["nai ao"] = {
            { text = "耐奥", comment = "nai ao" },
        },
        ["nai bu"] = {
            { text = "奈布", comment = "nai bu" },
            { text = "奶布", comment = "nai bu" },
        },
        ["nai ne"] = {
            { text = "奶呢", comment = "nai ne" },
        },
        ["nai ou"] = {
            { text = "奈欧", comment = "nai ou" },
            { text = "奈欧", comment = "nai ou" },
        },
        ["nai xu"] = {
            { text = "奈绪", comment = "nai xu" },
        },
        ["nai you"] = {
            { text = "奶油", comment = "nai you" },
            { text = "耐油", comment = "nai you" },
            { text = "奶优", comment = "nai you" },
        },
        ["nai yu"] = {
            { text = "奶浴", comment = "nai yu" },
        },
        ["nan a"] = {
            { text = "难啊", comment = "nan a" },
        },
        ["nan bu"] = {
            { text = "南部", comment = "nan bu" },
            { text = "难不", comment = "nan bu" },
        },
        ["nan huai"] = {
            { text = "南淮", comment = "nan huai" },
        },
        ["nan ou"] = {
            { text = "南欧", comment = "nan ou" },
        },
        ["nan ri"] = {
            { text = "南日", comment = "nan ri" },
            { text = "难日", comment = "nan ri" },
        },
        ["nan wo"] = {
            { text = "南卧", comment = "nan wo" },
        },
        ["nan ye"] = {
            { text = "南野", comment = "nan ye" },
            { text = "南冶", comment = "nan ye" },
        },
        ["nan yu"] = {
            { text = "难于", comment = "nan yu" },
            { text = "难遇", comment = "nan yu" },
            { text = "南屿", comment = "nan yu" },
            { text = "南宇", comment = "nan yu" },
            { text = "男浴", comment = "nan yu" },
            { text = "南玉", comment = "nan yu" },
            { text = "南域", comment = "nan yu" },
            { text = "南雨", comment = "nan yu" },
            { text = "南裕", comment = "nan yu" },
            { text = "难于", comment = "nan yu" },
            { text = "难遇", comment = "nan yu" },
            { text = "南屿", comment = "nan yu" },
            { text = "南宇", comment = "nan yu" },
            { text = "男浴", comment = "nan yu" },
            { text = "南玉", comment = "nan yu" },
            { text = "南域", comment = "nan yu" },
            { text = "南雨", comment = "nan yu" },
            { text = "南裕", comment = "nan yu" },
        },
        ["nan yue"] = {
            { text = "南岳", comment = "nan yue" },
            { text = "南粤", comment = "nan yue" },
            { text = "难约", comment = "nan yue" },
            { text = "南越", comment = "nan yue" },
            { text = "南约", comment = "nan yue" },
            { text = "南月", comment = "nan yue" },
        },
        ["nao ai"] = {
            { text = "脑癌", comment = "nao ai" },
        },
        ["nao an"] = {
            { text = "脑安", comment = "nao an" },
        },
        ["nao ye"] = {
            { text = "脑叶", comment = "nao ye" },
        },
        ["ne tai"] = {
            { text = "呢台", comment = "ne tai" },
        },
        ["ne you"] = {
            { text = "呢有", comment = "ne you" },
        },
        ["nei bu"] = {
            { text = "内部", comment = "nei bu" },
            { text = "内补", comment = "nei bu" },
            { text = "内埠", comment = "nei bu" },
        },
        ["nei huai"] = {
            { text = "内踝", comment = "nei huai" },
        },
        ["nei ri"] = {
            { text = "内日", comment = "nei ri" },
        },
        ["nen bu"] = {
            { text = "嫩不", comment = "nen bu" },
        },
        ["nen ou"] = {
            { text = "嫩藕", comment = "nen ou" },
        },
        ["neng ai"] = {
            { text = "能爱", comment = "neng ai" },
        },
        ["neng bu"] = {
            { text = "能不", comment = "neng bu" },
            { text = "能补", comment = "neng bu" },
        },
        ["neng ou"] = {
            { text = "能欧", comment = "neng ou" },
        },
        ["ni de ai"] = {
            { text = "你的爱", comment = "ni de ai" },
        },
        ["ni di"] = {
            { text = "你弟", comment = "ni di" },
            { text = "你地", comment = "ni di" },
            { text = "你滴", comment = "ni di" },
            { text = "泥地", comment = "ni di" },
            { text = "你哋", comment = "ni di" },
            { text = "你睇", comment = "ni di" },
            { text = "尼迪", comment = "ni di" },
            { text = "呢滴", comment = "ni di" },
        },
        ["ni die"] = {
            { text = "你爹", comment = "ni die" },
            { text = "你跌", comment = "ni die" },
        },
        ["ni diu"] = {
            { text = "你丢", comment = "ni diu" },
        },
        ["ni dou"] = {
            { text = "你都", comment = "ni dou" },
            { text = "泥斗", comment = "ni dou" },
        },
        ["ni duo"] = {
            { text = "你多", comment = "ni duo" },
        },
        ["ni e le"] = {
            { text = "你饿了", comment = "ni e le" },
        },
        ["ni e ma"] = {
            { text = "你饿吗", comment = "ni e ma" },
        },
        ["ni e xin"] = {
            { text = "你恶心", comment = "ni e xin" },
        },
        ["ni ei"] = {
            { text = "你诶", comment = "ni ei" },
            { text = "溺诶", comment = "ni ei" },
        },
        ["ni huai"] = {
            { text = "你坏", comment = "ni huai" },
        },
        ["ni nan"] = {
            { text = "呢喃", comment = "ni nan" },
        },
        ["ni nie"] = {
            { text = "你捏", comment = "ni nie" },
        },
        ["ni nin"] = {
            { text = "你您", comment = "ni nin" },
        },
        ["ni niu"] = {
            { text = "你牛", comment = "ni niu" },
        },
        ["ni ri"] = {
            { text = "尼日", comment = "ni ri" },
        },
        ["ni tan"] = {
            { text = "泥潭", comment = "ni tan" },
            { text = "你谈", comment = "ni tan" },
            { text = "泥炭", comment = "ni tan" },
        },
        ["ni te"] = {
            { text = "你特", comment = "ni te" },
            { text = "尼特", comment = "ni te" },
        },
        ["ni tei"] = {
            { text = "你忒", comment = "ni tei" },
        },
        ["ni tie"] = {
            { text = "你贴", comment = "ni tie" },
            { text = "铌铁", comment = "ni tie" },
        },
        ["ni tou"] = {
            { text = "泥头", comment = "ni tou" },
            { text = "你投", comment = "ni tou" },
            { text = "你头", comment = "ni tou" },
            { text = "你偷", comment = "ni tou" },
        },
        ["ni tu di"] = {
            { text = "你徒弟", comment = "ni tu di" },
        },
        ["ni tuan"] = {
            { text = "你团", comment = "ni tuan" },
        },
        ["ni wa"] = {
            { text = "你娃", comment = "ni wa" },
            { text = "你哇", comment = "ni wa" },
            { text = "泥瓦", comment = "ni wa" },
            { text = "泥洼", comment = "ni wa" },
        },
        ["ni wai"] = {
            { text = "腻歪", comment = "ni wai" },
        },
        ["ni wei"] = {
            { text = "腻味", comment = "ni wei" },
            { text = "你为", comment = "ni wei" },
            { text = "倪伟", comment = "ni wei" },
            { text = "逆位", comment = "ni wei" },
            { text = "泥尾", comment = "ni wei" },
        },
        ["ni wen"] = {
            { text = "你问", comment = "ni wen" },
            { text = "拟文", comment = "ni wen" },
            { text = "逆温", comment = "ni wen" },
            { text = "倪文", comment = "ni wen" },
            { text = "倪雯", comment = "ni wen" },
        },
        ["nie bu"] = {
            { text = "颞部", comment = "nie bu" },
        },
        ["nie dai"] = {
            { text = "镍带", comment = "nie dai" },
        },
        ["nie le"] = {
            { text = "捏了", comment = "nie le" },
        },
        ["nie ma"] = {
            { text = "捏吗", comment = "nie ma" },
            { text = "捏嘛", comment = "nie ma" },
        },
        ["nie wo"] = {
            { text = "捏我", comment = "nie wo" },
        },
        ["nie xin"] = {
            { text = "聂鑫", comment = "nie xin" },
            { text = "聂欣", comment = "nie xin" },
        },
        ["nie ye"] = {
            { text = "颞叶", comment = "nie ye" },
            { text = "镍业", comment = "nie ye" },
        },
        ["nie yu"] = {
            { text = "聂宇", comment = "nie yu" },
            { text = "聂玉", comment = "nie yu" },
        },
        ["nin an"] = {
            { text = "您按", comment = "nin an" },
        },
        ["nin ye"] = {
            { text = "您也", comment = "nin ye" },
        },
        ["nin yu"] = {
            { text = "您与", comment = "nin yu" },
            { text = "您与", comment = "nin yu" },
        },
        ["ning an"] = {
            { text = "宁安", comment = "ning an" },
        },
        ["ning bu"] = {
            { text = "拧不", comment = "ning bu" },
        },
        ["ning di"] = {
            { text = "宁蒂", comment = "ning di" },
        },
        ["ning e"] = {
            { text = "狞恶", comment = "ning e" },
        },
        ["ning huai"] = {
            { text = "宁淮", comment = "ning huai" },
        },
        ["ning ou"] = {
            { text = "宁鸥", comment = "ning ou" },
        },
        ["ning ri"] = {
            { text = "宁日", comment = "ning ri" },
        },
        ["ning wei"] = {
            { text = "宁围", comment = "ning wei" },
            { text = "宁伟", comment = "ning wei" },
            { text = "宁卫", comment = "ning wei" },
        },
        ["ning xu"] = {
            { text = "宁旭", comment = "ning xu" },
        },
        ["ning ye"] = {
            { text = "凝噎", comment = "ning ye" },
            { text = "凝液", comment = "ning ye" },
        },
        ["niu a"] = {
            { text = "牛啊", comment = "niu a" },
            { text = "妞啊", comment = "niu a" },
        },
        ["niu ai"] = {
            { text = "纽埃", comment = "niu ai" },
        },
        ["niu ao"] = {
            { text = "纽澳", comment = "niu ao" },
        },
        ["niu di"] = {
            { text = "牛地", comment = "niu di" },
            { text = "纽迪", comment = "niu di" },
        },
        ["niu en"] = {
            { text = "纽恩", comment = "niu en" },
        },
        ["niu fo"] = {
            { text = "牛佛", comment = "niu fo" },
        },
        ["nue"] = {
            { text = "虐", comment = "nue" },
            { text = "疟", comment = "nue" },
        },
        ["nue wo"] = {
            { text = "虐我", comment = "nue wo" },
        },
        ["nuo bu"] = {
            { text = "诺布", comment = "nuo bu" },
        },
        ["nuo ou"] = {
            { text = "诺欧", comment = "nuo ou" },
        },
        ["nv duo"] = {
            { text = "女多", comment = "nv duo" },
        },
        ["nv e"] = {
            { text = "女鹅", comment = "nv e" },
        },
        ["o a"] = {
            { text = "哦啊", comment = "o a" },
        },
        ["o an"] = {
            { text = "哦按", comment = "o an" },
        },
        ["o o"] = {
            { text = "哦哦", comment = "o o" },
            { text = "噢噢", comment = "o o" },
            { text = "哦噢", comment = "o o" },
            { text = "喔噢", comment = "o o" },
        },
        ["o o hao"] = {
            { text = "哦哦好", comment = "o o hao" },
        },
        ["o o o o"] = {
            { text = "噢噢噢噢", comment = "o o o o" },
        },
        ["o ya"] = {
            { text = "哦呀", comment = "o ya" },
        },
        ["o ye"] = {
            { text = "哦也", comment = "o ye" },
            { text = "噢耶", comment = "o ye" },
        },
        ["o you"] = {
            { text = "哦呦", comment = "o you" },
            { text = "哦唷", comment = "o you" },
        },
        ["ou"] = {
            { text = "偶", comment = "ou" },
            { text = "欧", comment = "ou" },
            { text = "呕", comment = "ou" },
            { text = "藕", comment = "ou" },
            { text = "殴", comment = "ou" },
            { text = "鸥", comment = "ou" },
            { text = "区", comment = "ou" },
            { text = "瓯", comment = "ou" },
            { text = "耦", comment = "ou" },
            { text = "怄", comment = "ou" },
            { text = "讴", comment = "ou" },
            { text = "沤", comment = "ou" },
            { text = "吽", comment = "ou" },
            { text = "𠙶", comment = "ou" },
            { text = "𬉼", comment = "ou" },
            { text = "𫭟", comment = "ou" },
        },
        ["ou a"] = {
            { text = "偶啊", comment = "ou a" },
        },
        ["ou ai"] = {
            { text = "偶爱", comment = "ou ai" },
            { text = "呕埃", comment = "ou ai" },
        },
        ["ou ai guo"] = {
            { text = "欧爱国", comment = "ou ai guo" },
        },
        ["ou an"] = {
            { text = "欧安", comment = "ou an" },
        },
        ["ou ba"] = {
            { text = "欧巴", comment = "ou ba" },
            { text = "偶吧", comment = "ou ba" },
            { text = "欧芭", comment = "ou ba" },
            { text = "欧霸", comment = "ou ba" },
        },
        ["ou bai"] = {
            { text = "欧柏", comment = "ou bai" },
        },
        ["ou ban"] = {
            { text = "欧版", comment = "ou ban" },
            { text = "偶伴", comment = "ou ban" },
        },
        ["ou bang"] = {
            { text = "欧邦", comment = "ou bang" },
        },
        ["ou bao"] = {
            { text = "欧宝", comment = "ou bao" },
            { text = "欧包", comment = "ou bao" },
            { text = "欧堡", comment = "ou bao" },
        },
        ["ou bei"] = {
            { text = "瓯北", comment = "ou bei" },
            { text = "欧贝", comment = "ou bei" },
        },
        ["ou ben"] = {
            { text = "欧本", comment = "ou ben" },
        },
        ["ou bi"] = {
            { text = "欧比", comment = "ou bi" },
        },
        ["ou bian"] = {
            { text = "欧变", comment = "ou bian" },
        },
        ["ou biao"] = {
            { text = "欧标", comment = "ou biao" },
        },
        ["ou bing"] = {
            { text = "藕饼", comment = "ou bing" },
        },
        ["ou bo"] = {
            { text = "欧泊", comment = "ou bo" },
            { text = "欧博", comment = "ou bo" },
            { text = "欧波", comment = "ou bo" },
            { text = "欧铂", comment = "ou bo" },
        },
        ["ou bu"] = {
            { text = "欧布", comment = "ou bu" },
            { text = "偶不", comment = "ou bu" },
        },
        ["ou bu zhang"] = {
            { text = "欧部长", comment = "ou bu zhang" },
        },
        ["ou cai"] = {
            { text = "瓯菜", comment = "ou cai" },
            { text = "欧彩", comment = "ou cai" },
        },
        ["ou cao"] = {
            { text = "欧操", comment = "ou cao" },
        },
        ["ou ceng"] = {
            { text = "欧层", comment = "ou ceng" },
        },
        ["ou cha"] = {
            { text = "欧查", comment = "ou cha" },
            { text = "欧插", comment = "ou cha" },
        },
        ["ou chang"] = {
            { text = "欧畅", comment = "ou chang" },
        },
        ["ou chao"] = {
            { text = "欧超", comment = "ou chao" },
        },
        ["ou chen"] = {
            { text = "欧辰", comment = "ou chen" },
        },
        ["ou cheng"] = {
            { text = "偶成", comment = "ou cheng" },
            { text = "欧城", comment = "ou cheng" },
            { text = "欧成", comment = "ou cheng" },
            { text = "欧诚", comment = "ou cheng" },
        },
        ["ou chi"] = {
            { text = "藕池", comment = "ou chi" },
            { text = "欧驰", comment = "ou chi" },
        },
        ["ou chong"] = {
            { text = "欧冲", comment = "ou chong" },
        },
        ["ou chu"] = {
            { text = "呕出", comment = "ou chu" },
            { text = "欧楚", comment = "ou chu" },
        },
        ["ou chuang"] = {
            { text = "欧创", comment = "ou chuang" },
        },
        ["ou cong"] = {
            { text = "欧聪", comment = "ou cong" },
        },
        ["ou cuo le"] = {
            { text = "偶错了", comment = "ou cuo le" },
        },
        ["ou da"] = {
            { text = "殴打", comment = "ou da" },
            { text = "欧达", comment = "ou da" },
            { text = "欧大", comment = "ou da" },
        },
        ["ou dai"] = {
            { text = "藕带", comment = "ou dai" },
            { text = "欧代", comment = "ou dai" },
        },
        ["ou dan"] = {
            { text = "欧丹", comment = "ou dan" },
            { text = "偶氮", comment = "ou dan" },
        },
        ["ou de"] = {
            { text = "偶的", comment = "ou de" },
            { text = "欧德", comment = "ou de" },
            { text = "偶得", comment = "ou de" },
            { text = "欧得", comment = "ou de" },
            { text = "欧地", comment = "ou de" },
        },
        ["ou de ke"] = {
            { text = "欧德克", comment = "ou de ke" },
        },
        ["ou de li"] = {
            { text = "欧德利", comment = "ou de li" },
        },
        ["ou de ya"] = {
            { text = "欧德雅", comment = "ou de ya" },
        },
        ["ou deng"] = {
            { text = "欧登", comment = "ou deng" },
        },
        ["ou di"] = {
            { text = "欧弟", comment = "ou di" },
            { text = "欧迪", comment = "ou di" },
            { text = "欧帝", comment = "ou di" },
            { text = "欧地", comment = "ou di" },
            { text = "偶滴", comment = "ou di" },
        },
        ["ou dian"] = {
            { text = "欧典", comment = "ou dian" },
            { text = "欧点", comment = "ou dian" },
        },
        ["ou ding"] = {
            { text = "藕丁", comment = "ou ding" },
            { text = "欧鼎", comment = "ou ding" },
        },
        ["ou dong"] = {
            { text = "欧东", comment = "ou dong" },
        },
        ["ou dou"] = {
            { text = "殴斗", comment = "ou dou" },
            { text = "偶都", comment = "ou dou" },
        },
        ["ou du"] = {
            { text = "偶读", comment = "ou du" },
            { text = "欧度", comment = "ou du" },
        },
        ["ou duan"] = {
            { text = "藕断", comment = "ou duan" },
        },
        ["ou dui"] = {
            { text = "偶对", comment = "ou dui" },
        },
        ["ou dun"] = {
            { text = "欧顿", comment = "ou dun" },
            { text = "欧盾", comment = "ou dun" },
        },
        ["ou duo"] = {
            { text = "欧多", comment = "ou duo" },
        },
        ["ou en"] = {
            { text = "欧恩", comment = "ou en" },
        },
        ["ou er"] = {
            { text = "偶尔", comment = "ou er" },
            { text = "欧尔", comment = "ou er" },
            { text = "欧儿", comment = "ou er" },
            { text = "偶而", comment = "ou er" },
        },
        ["ou fa"] = {
            { text = "偶发", comment = "ou fa" },
        },
        ["ou fan"] = {
            { text = "欧凡", comment = "ou fan" },
            { text = "偶犯", comment = "ou fan" },
        },
        ["ou fang"] = {
            { text = "欧方", comment = "ou fang" },
            { text = "欧芳", comment = "ou fang" },
        },
        ["ou fei"] = {
            { text = "欧非", comment = "ou fei" },
            { text = "欧菲", comment = "ou fei" },
            { text = "欧飞", comment = "ou fei" },
            { text = "沤肥", comment = "ou fei" },
        },
        ["ou fen"] = {
            { text = "藕粉", comment = "ou fen" },
        },
        ["ou feng"] = {
            { text = "欧风", comment = "ou feng" },
        },
        ["ou fu"] = {
            { text = "欧服", comment = "ou fu" },
            { text = "欧福", comment = "ou fu" },
        },
        ["ou gan"] = {
            { text = "偶感", comment = "ou gan" },
            { text = "瓯柑", comment = "ou gan" },
        },
        ["ou gang"] = {
            { text = "欧刚", comment = "ou gang" },
            { text = "欧港", comment = "ou gang" },
        },
        ["ou gao"] = {
            { text = "欧高", comment = "ou gao" },
        },
        ["ou ge"] = {
            { text = "讴歌", comment = "ou ge" },
            { text = "欧哥", comment = "ou ge" },
            { text = "欧歌", comment = "ou ge" },
            { text = "欧格", comment = "ou ge" },
        },
        ["ou gen"] = {
            { text = "欧根", comment = "ou gen" },
        },
        ["ou gong"] = {
            { text = "欧共", comment = "ou gong" },
            { text = "欧工", comment = "ou gong" },
        },
        ["ou gu"] = {
            { text = "欧股", comment = "ou gu" },
        },
        ["ou guan"] = {
            { text = "欧冠", comment = "ou guan" },
        },
        ["ou guang"] = {
            { text = "欧光", comment = "ou guang" },
        },
        ["ou gui"] = {
            { text = "欧规", comment = "ou gui" },
        },
        ["ou guo"] = {
            { text = "欧国", comment = "ou guo" },
        },
        ["ou hai"] = {
            { text = "瓯海", comment = "ou hai" },
            { text = "欧海", comment = "ou hai" },
            { text = "偶还", comment = "ou hai" },
        },
        ["ou hai shi"] = {
            { text = "偶还是", comment = "ou hai shi" },
        },
        ["ou han"] = {
            { text = "欧韩", comment = "ou han" },
        },
        ["ou hang"] = {
            { text = "欧航", comment = "ou hang" },
        },
        ["ou hao"] = {
            { text = "欧豪", comment = "ou hao" },
        },
        ["ou he"] = {
            { text = "耦合", comment = "ou he" },
            { text = "藕合", comment = "ou he" },
            { text = "偶合", comment = "ou he" },
            { text = "藕盒", comment = "ou he" },
            { text = "藕荷", comment = "ou he" },
        },
        ["ou heng"] = {
            { text = "欧恒", comment = "ou heng" },
        },
        ["ou hong"] = {
            { text = "欧红", comment = "ou hong" },
        },
        ["ou hou"] = {
            { text = "呕吼", comment = "ou hou" },
            { text = "欧吼", comment = "ou hou" },
            { text = "欧后", comment = "ou hou" },
        },
        ["ou hu"] = {
            { text = "欧虎", comment = "ou hu" },
        },
        ["ou hua"] = {
            { text = "欧化", comment = "ou hua" },
            { text = "欧华", comment = "ou hua" },
        },
        ["ou huan"] = {
            { text = "欧欢", comment = "ou huan" },
            { text = "偶还", comment = "ou huan" },
        },
        ["ou huang"] = {
            { text = "欧皇", comment = "ou huang" },
        },
        ["ou hui"] = {
            { text = "偶会", comment = "ou hui" },
            { text = "欧惠", comment = "ou hui" },
            { text = "欧辉", comment = "ou hui" },
            { text = "欧蕙", comment = "ou hui" },
            { text = "欧汇", comment = "ou hui" },
            { text = "藕灰", comment = "ou hui" },
        },
        ["ou huo"] = {
            { text = "偶或", comment = "ou huo" },
            { text = "欧货", comment = "ou huo" },
            { text = "怄火", comment = "ou huo" },
        },
        ["ou ji"] = {
            { text = "偶记", comment = "ou ji" },
            { text = "欧吉", comment = "ou ji" },
            { text = "欧基", comment = "ou ji" },
            { text = "欧记", comment = "ou ji" },
        },
        ["ou jia"] = {
            { text = "偶家", comment = "ou jia" },
            { text = "藕夹", comment = "ou jia" },
            { text = "欧家", comment = "ou jia" },
            { text = "欧佳", comment = "ou jia" },
            { text = "欧嘉", comment = "ou jia" },
            { text = "欧加", comment = "ou jia" },
        },
        ["ou jian"] = {
            { text = "偶见", comment = "ou jian" },
            { text = "藕尖", comment = "ou jian" },
            { text = "欧健", comment = "ou jian" },
        },
        ["ou jiang"] = {
            { text = "瓯江", comment = "ou jiang" },
            { text = "欧江", comment = "ou jiang" },
        },
        ["ou jiao"] = {
            { text = "欧娇", comment = "ou jiao" },
        },
        ["ou jie"] = {
            { text = "藕节", comment = "ou jie" },
            { text = "欧姐", comment = "ou jie" },
            { text = "欧洁", comment = "ou jie" },
            { text = "欧杰", comment = "ou jie" },
            { text = "鸥姐", comment = "ou jie" },
            { text = "欧捷", comment = "ou jie" },
        },
        ["ou jin"] = {
            { text = "欧锦", comment = "ou jin" },
        },
        ["ou jin jin"] = {
            { text = "欧金金", comment = "ou jin jin" },
        },
        ["ou jing"] = {
            { text = "欧静", comment = "ou jing" },
            { text = "欧景", comment = "ou jing" },
            { text = "欧井", comment = "ou jing" },
        },
        ["ou jing li"] = {
            { text = "欧经理", comment = "ou jing li" },
        },
        ["ou jiu"] = {
            { text = "偶就", comment = "ou jiu" },
            { text = "偶久", comment = "ou jiu" },
        },
        ["ou ju"] = {
            { text = "欧菊", comment = "ou ju" },
            { text = "偶剧", comment = "ou ju" },
            { text = "欧局", comment = "ou ju" },
        },
        ["ou juan"] = {
            { text = "欧娟", comment = "ou juan" },
        },
        ["ou jue"] = {
            { text = "欧爵", comment = "ou jue" },
        },
        ["ou jue de"] = {
            { text = "偶觉得", comment = "ou jue de" },
        },
        ["ou jun"] = {
            { text = "欧俊", comment = "ou jun" },
            { text = "欧军", comment = "ou jun" },
            { text = "欧郡", comment = "ou jun" },
        },
        ["ou ka"] = {
            { text = "欧卡", comment = "ou ka" },
        },
        ["ou kai"] = {
            { text = "欧凯", comment = "ou kai" },
            { text = "欧开", comment = "ou kai" },
            { text = "欧楷", comment = "ou kai" },
        },
        ["ou kan"] = {
            { text = "偶看", comment = "ou kan" },
        },
        ["ou kang"] = {
            { text = "欧康", comment = "ou kang" },
        },
        ["ou ke"] = {
            { text = "欧克", comment = "ou ke" },
            { text = "欧科", comment = "ou ke" },
            { text = "欧可", comment = "ou ke" },
            { text = "欧珂", comment = "ou ke" },
            { text = "欧客", comment = "ou ke" },
        },
        ["ou ke yi"] = {
            { text = "偶可以", comment = "ou ke yi" },
        },
        ["ou ken"] = {
            { text = "欧肯", comment = "ou ken" },
        },
        ["ou kong"] = {
            { text = "欧空", comment = "ou kong" },
        },
        ["ou ku"] = {
            { text = "欧酷", comment = "ou ku" },
        },
        ["ou kuai"] = {
            { text = "欧快", comment = "ou kuai" },
        },
        ["ou kuan"] = {
            { text = "欧款", comment = "ou kuan" },
        },
        ["ou kun"] = {
            { text = "欧坤", comment = "ou kun" },
        },
        ["ou la"] = {
            { text = "欧拉", comment = "ou la" },
            { text = "欧啦", comment = "ou la" },
        },
        ["ou lai"] = {
            { text = "偶来", comment = "ou lai" },
            { text = "欧莱", comment = "ou lai" },
        },
        ["ou lai de"] = {
            { text = "欧莱德", comment = "ou lai de" },
        },
        ["ou lai ke"] = {
            { text = "欧莱克", comment = "ou lai ke" },
        },
        ["ou lai mei"] = {
            { text = "欧莱美", comment = "ou lai mei" },
        },
        ["ou lai te"] = {
            { text = "欧莱特", comment = "ou lai te" },
        },
        ["ou lan"] = {
            { text = "欧兰", comment = "ou lan" },
            { text = "欧蓝", comment = "ou lan" },
        },
        ["ou lan de"] = {
            { text = "欧蓝德", comment = "ou lan de" },
        },
        ["ou lan te"] = {
            { text = "欧兰特", comment = "ou lan te" },
        },
        ["ou lang"] = {
            { text = "欧朗", comment = "ou lang" },
        },
        ["ou lao shi"] = {
            { text = "欧老师", comment = "ou lao shi" },
        },
        ["ou le"] = {
            { text = "欧了", comment = "ou le" },
            { text = "欧乐", comment = "ou le" },
            { text = "呕了", comment = "ou le" },
            { text = "偶了", comment = "ou le" },
        },
        ["ou lei"] = {
            { text = "欧蕾", comment = "ou lei" },
        },
        ["ou li"] = {
            { text = "欧力", comment = "ou li" },
            { text = "欧丽", comment = "ou li" },
            { text = "欧利", comment = "ou li" },
            { text = "欧立", comment = "ou li" },
        },
        ["ou lian"] = {
            { text = "欧联", comment = "ou lian" },
            { text = "偶练", comment = "ou lian" },
            { text = "偶联", comment = "ou lian" },
        },
        ["ou liang"] = {
            { text = "欧亮", comment = "ou liang" },
        },
        ["ou lin"] = {
            { text = "欧琳", comment = "ou lin" },
            { text = "欧林", comment = "ou lin" },
        },
        ["ou ling"] = {
            { text = "欧玲", comment = "ou ling" },
            { text = "欧菱", comment = "ou ling" },
            { text = "欧铃", comment = "ou ling" },
            { text = "欧灵", comment = "ou ling" },
        },
        ["ou long"] = {
            { text = "欧龙", comment = "ou long" },
            { text = "欧珑", comment = "ou long" },
            { text = "欧隆", comment = "ou long" },
        },
        ["ou lu"] = {
            { text = "欧陆", comment = "ou lu" },
            { text = "欧路", comment = "ou lu" },
            { text = "欧露", comment = "ou lu" },
            { text = "欧麓", comment = "ou lu" },
        },
        ["ou lun"] = {
            { text = "欧伦", comment = "ou lun" },
        },
        ["ou luo"] = {
            { text = "欧罗", comment = "ou luo" },
        },
        ["ou lv"] = {
            { text = "欧绿", comment = "ou lv" },
        },
        ["ou ma"] = {
            { text = "欧码", comment = "ou ma" },
            { text = "欧玛", comment = "ou ma" },
            { text = "偶妈", comment = "ou ma" },
        },
        ["ou mai"] = {
            { text = "欧迈", comment = "ou mai" },
            { text = "欧麦", comment = "ou mai" },
        },
        ["ou man"] = {
            { text = "欧曼", comment = "ou man" },
        },
        ["ou mao"] = {
            { text = "欧贸", comment = "ou mao" },
        },
        ["ou mei"] = {
            { text = "欧美", comment = "ou mei" },
            { text = "欧梅", comment = "ou mei" },
        },
        ["ou men"] = {
            { text = "偶们", comment = "ou men" },
        },
        ["ou meng"] = {
            { text = "欧盟", comment = "ou meng" },
            { text = "欧蒙", comment = "ou meng" },
            { text = "欧梦", comment = "ou meng" },
        },
        ["ou mi"] = {
            { text = "欧米", comment = "ou mi" },
        },
        ["ou miao"] = {
            { text = "欧庙", comment = "ou miao" },
        },
        ["ou min"] = {
            { text = "欧敏", comment = "ou min" },
        },
        ["ou ming"] = {
            { text = "欧明", comment = "ou ming" },
            { text = "欧铭", comment = "ou ming" },
        },
        ["ou mo"] = {
            { text = "欧模", comment = "ou mo" },
        },
        ["ou mu"] = {
            { text = "欧姆", comment = "ou mu" },
            { text = "欧慕", comment = "ou mu" },
        },
        ["ou na"] = {
            { text = "欧娜", comment = "ou na" },
        },
        ["ou nai"] = {
            { text = "欧耐", comment = "ou nai" },
        },
        ["ou nan"] = {
            { text = "欧南", comment = "ou nan" },
            { text = "瓯南", comment = "ou nan" },
        },
        ["ou nei"] = {
            { text = "欧内", comment = "ou nei" },
        },
        ["ou neng"] = {
            { text = "欧能", comment = "ou neng" },
        },
        ["ou neng da"] = {
            { text = "欧能达", comment = "ou neng da" },
        },
        ["ou ni"] = {
            { text = "欧尼", comment = "ou ni" },
            { text = "欧妮", comment = "ou ni" },
        },
        ["ou niao"] = {
            { text = "鸥鸟", comment = "ou niao" },
        },
        ["ou ning"] = {
            { text = "欧宁", comment = "ou ning" },
        },
        ["ou nuo"] = {
            { text = "欧诺", comment = "ou nuo" },
        },
        ["ou ou"] = {
            { text = "偶偶", comment = "ou ou" },
            { text = "欧欧", comment = "ou ou" },
            { text = "呕呕", comment = "ou ou" },
        },
        ["ou pa"] = {
            { text = "偶怕", comment = "ou pa" },
        },
        ["ou pa si"] = {
            { text = "欧帕斯", comment = "ou pa si" },
        },
        ["ou pai"] = {
            { text = "欧派", comment = "ou pai" },
        },
        ["ou pan"] = {
            { text = "欧盘", comment = "ou pan" },
        },
        ["ou pao"] = {
            { text = "欧泡", comment = "ou pao" },
        },
        ["ou pei"] = {
            { text = "欧赔", comment = "ou pei" },
            { text = "欧佩", comment = "ou pei" },
        },
        ["ou peng"] = {
            { text = "欧朋", comment = "ou peng" },
            { text = "欧鹏", comment = "ou peng" },
            { text = "鸥鹏", comment = "ou peng" },
        },
        ["ou pian"] = {
            { text = "藕片", comment = "ou pian" },
        },
        ["ou pin"] = {
            { text = "欧品", comment = "ou pin" },
        },
        ["ou ping"] = {
            { text = "欧平", comment = "ou ping" },
        },
        ["ou po"] = {
            { text = "欧珀", comment = "ou po" },
        },
        ["ou pu"] = {
            { text = "欧普", comment = "ou pu" },
            { text = "欧朴", comment = "ou pu" },
            { text = "欧浦", comment = "ou pu" },
        },
        ["ou qi"] = {
            { text = "怄气", comment = "ou qi" },
            { text = "欧气", comment = "ou qi" },
            { text = "欧奇", comment = "ou qi" },
        },
        ["ou qia"] = {
            { text = "欧洽", comment = "ou qia" },
        },
        ["ou qian"] = {
            { text = "欧倩", comment = "ou qian" },
        },
        ["ou qiang"] = {
            { text = "欧强", comment = "ou qiang" },
        },
        ["ou qin"] = {
            { text = "欧芹", comment = "ou qin" },
            { text = "欧琴", comment = "ou qin" },
        },
        ["ou qing"] = {
            { text = "欧青", comment = "ou qing" },
        },
        ["ou qiu"] = {
            { text = "欧秋", comment = "ou qiu" },
        },
        ["ou qu"] = {
            { text = "偶去", comment = "ou qu" },
            { text = "藕渠", comment = "ou qu" },
        },
        ["ou quan"] = {
            { text = "欧泉", comment = "ou quan" },
        },
        ["ou qun"] = {
            { text = "欧群", comment = "ou qun" },
        },
        ["ou ran"] = {
            { text = "偶然", comment = "ou ran" },
        },
        ["ou ran xing"] = {
            { text = "偶然性", comment = "ou ran xing" },
        },
        ["ou re"] = {
            { text = "欧热", comment = "ou re" },
        },
        ["ou ren"] = {
            { text = "偶人", comment = "ou ren" },
            { text = "怄人", comment = "ou ren" },
            { text = "欧人", comment = "ou ren" },
        },
        ["ou ri"] = {
            { text = "欧日", comment = "ou ri" },
        },
        ["ou rong"] = {
            { text = "欧荣", comment = "ou rong" },
            { text = "欧蓉", comment = "ou rong" },
        },
        ["ou ru"] = {
            { text = "殴辱", comment = "ou ru" },
        },
        ["ou rui"] = {
            { text = "欧瑞", comment = "ou rui" },
            { text = "欧睿", comment = "ou rui" },
            { text = "欧锐", comment = "ou rui" },
        },
        ["ou rui te"] = {
            { text = "欧瑞特", comment = "ou rui te" },
        },
        ["ou ruo"] = {
            { text = "欧若", comment = "ou ruo" },
        },
        ["ou sa"] = {
            { text = "欧萨", comment = "ou sa" },
        },
        ["ou sai"] = {
            { text = "欧塞", comment = "ou sai" },
            { text = "欧赛", comment = "ou sai" },
        },
        ["ou san"] = {
            { text = "欧三", comment = "ou san" },
        },
        ["ou sang"] = {
            { text = "欧桑", comment = "ou sang" },
        },
        ["ou sao"] = {
            { text = "欧嫂", comment = "ou sao" },
        },
        ["ou se"] = {
            { text = "藕色", comment = "ou se" },
        },
        ["ou sen"] = {
            { text = "欧森", comment = "ou sen" },
        },
        ["ou sha"] = {
            { text = "欧莎", comment = "ou sha" },
        },
        ["ou shan"] = {
            { text = "欧珊", comment = "ou shan" },
        },
        ["ou shang"] = {
            { text = "欧尚", comment = "ou shang" },
        },
        ["ou shao"] = {
            { text = "欧少", comment = "ou shao" },
        },
        ["ou she"] = {
            { text = "欧舍", comment = "ou she" },
        },
        ["ou shen"] = {
            { text = "欧神", comment = "ou shen" },
            { text = "欧申", comment = "ou shen" },
        },
        ["ou sheng"] = {
            { text = "欧盛", comment = "ou sheng" },
            { text = "欧生", comment = "ou sheng" },
            { text = "欧胜", comment = "ou sheng" },
            { text = "欧圣", comment = "ou sheng" },
            { text = "欧晟", comment = "ou sheng" },
        },
        ["ou shi"] = {
            { text = "欧式", comment = "ou shi" },
            { text = "偶是", comment = "ou shi" },
            { text = "欧时", comment = "ou shi" },
            { text = "欧仕", comment = "ou shi" },
        },
        ["ou shi da"] = {
            { text = "欧仕达", comment = "ou shi da" },
        },
        ["ou shi ji"] = {
            { text = "欧式机", comment = "ou shi ji" },
        },
        ["ou shu"] = {
            { text = "偶数", comment = "ou shu" },
            { text = "欧树", comment = "ou shu" },
            { text = "欧叔", comment = "ou shu" },
            { text = "欧束", comment = "ou shu" },
        },
        ["ou shu dan"] = {
            { text = "欧舒丹", comment = "ou shu dan" },
        },
        ["ou shu ji"] = {
            { text = "欧书记", comment = "ou shu ji" },
        },
        ["ou shu shi"] = {
            { text = "欧舒适", comment = "ou shu shi" },
        },
        ["ou shui"] = {
            { text = "欧水", comment = "ou shui" },
        },
        ["ou shun"] = {
            { text = "欧顺", comment = "ou shun" },
        },
        ["ou shuo"] = {
            { text = "偶说", comment = "ou shuo" },
        },
        ["ou si"] = {
            { text = "藕丝", comment = "ou si" },
            { text = "呕死", comment = "ou si" },
            { text = "欧斯", comment = "ou si" },
            { text = "欧思", comment = "ou si" },
        },
        ["ou song"] = {
            { text = "欧松", comment = "ou song" },
        },
        ["ou sou"] = {
            { text = "欧搜", comment = "ou sou" },
        },
        ["ou su"] = {
            { text = "偶素", comment = "ou su" },
        },
        ["ou sun"] = {
            { text = "欧笋", comment = "ou sun" },
        },
        ["ou suo"] = {
            { text = "欧索", comment = "ou suo" },
        },
        ["ou ta"] = {
            { text = "欧塔", comment = "ou ta" },
        },
        ["ou tai"] = {
            { text = "欧泰", comment = "ou tai" },
            { text = "欧太", comment = "ou tai" },
        },
        ["ou tang"] = {
            { text = "藕塘", comment = "ou tang" },
            { text = "藕汤", comment = "ou tang" },
        },
        ["ou tao"] = {
            { text = "欧涛", comment = "ou tao" },
        },
        ["ou te"] = {
            { text = "欧特", comment = "ou te" },
        },
        ["ou teng"] = {
            { text = "欧腾", comment = "ou teng" },
        },
        ["ou ti"] = {
            { text = "欧体", comment = "ou ti" },
        },
        ["ou tian"] = {
            { text = "偶天", comment = "ou tian" },
        },
        ["ou tiao"] = {
            { text = "藕条", comment = "ou tiao" },
        },
        ["ou tie"] = {
            { text = "欧铁", comment = "ou tie" },
        },
        ["ou ting"] = {
            { text = "鸥汀", comment = "ou ting" },
            { text = "欧婷", comment = "ou ting" },
        },
        ["ou tong"] = {
            { text = "欧通", comment = "ou tong" },
            { text = "偶同", comment = "ou tong" },
        },
        ["ou tu"] = {
            { text = "呕吐", comment = "ou tu" },
            { text = "欧图", comment = "ou tu" },
        },
        ["ou tuo"] = {
            { text = "欧拓", comment = "ou tuo" },
        },
        ["ou wai"] = {
            { text = "鸥外", comment = "ou wai" },
        },
        ["ou wan"] = {
            { text = "偶玩", comment = "ou wan" },
            { text = "藕丸", comment = "ou wan" },
        },
        ["ou wang"] = {
            { text = "瓯网", comment = "ou wang" },
            { text = "欧王", comment = "ou wang" },
            { text = "藕王", comment = "ou wang" },
        },
        ["ou wei"] = {
            { text = "欧威", comment = "ou wei" },
            { text = "欧维", comment = "ou wei" },
            { text = "欧伟", comment = "ou wei" },
        },
        ["ou wen"] = {
            { text = "欧文", comment = "ou wen" },
            { text = "瓯文", comment = "ou wen" },
            { text = "欧雯", comment = "ou wen" },
        },
        ["ou wo"] = {
            { text = "欧沃", comment = "ou wo" },
        },
        ["ou wu"] = {
            { text = "欧五", comment = "ou wu" },
        },
        ["ou xi"] = {
            { text = "欧西", comment = "ou xi" },
            { text = "欧系", comment = "ou xi" },
        },
        ["ou xi huan"] = {
            { text = "偶喜欢", comment = "ou xi huan" },
        },
        ["ou xia"] = {
            { text = "欧霞", comment = "ou xia" },
        },
        ["ou xian"] = {
            { text = "偶先", comment = "ou xian" },
            { text = "偶现", comment = "ou xian" },
            { text = "欧线", comment = "ou xian" },
        },
        ["ou xian sheng"] = {
            { text = "欧先生", comment = "ou xian sheng" },
        },
        ["ou xiang"] = {
            { text = "偶像", comment = "ou xiang" },
            { text = "欧翔", comment = "ou xiang" },
            { text = "欧香", comment = "ou xiang" },
            { text = "欧橡", comment = "ou xiang" },
            { text = "欧享", comment = "ou xiang" },
            { text = "呕像", comment = "ou xiang" },
            { text = "偶想", comment = "ou xiang" },
        },
        ["ou xiang hua"] = {
            { text = "偶像化", comment = "ou xiang hua" },
        },
        ["ou xiao"] = {
            { text = "欧晓", comment = "ou xiao" },
        },
        ["ou xie"] = {
            { text = "欧谢", comment = "ou xie" },
        },
        ["ou xin"] = {
            { text = "呕心", comment = "ou xin" },
            { text = "欧信", comment = "ou xin" },
            { text = "欧新", comment = "ou xin" },
        },
        ["ou xing"] = {
            { text = "欧兴", comment = "ou xing" },
            { text = "欧星", comment = "ou xing" },
        },
        ["ou xiu"] = {
            { text = "瓯绣", comment = "ou xiu" },
        },
        ["ou xu"] = {
            { text = "欧旭", comment = "ou xu" },
        },
        ["ou xuan"] = {
            { text = "欧萱", comment = "ou xuan" },
            { text = "欧璇", comment = "ou xuan" },
            { text = "欧选", comment = "ou xuan" },
        },
        ["ou xue"] = {
            { text = "呕血", comment = "ou xue" },
            { text = "欧雪", comment = "ou xue" },
        },
        ["ou xun"] = {
            { text = "欧迅", comment = "ou xun" },
            { text = "欧讯", comment = "ou xun" },
        },
        ["ou ya"] = {
            { text = "欧亚", comment = "ou ya" },
            { text = "欧雅", comment = "ou ya" },
        },
        ["ou yan"] = {
            { text = "欧燕", comment = "ou yan" },
            { text = "欧艳", comment = "ou yan" },
        },
        ["ou yang"] = {
            { text = "欧阳", comment = "ou yang" },
            { text = "欧洋", comment = "ou yang" },
        },
        ["ou yang le"] = {
            { text = "欧阳乐", comment = "ou yang le" },
        },
        ["ou yao"] = {
            { text = "偶要", comment = "ou yao" },
        },
        ["ou yao qu"] = {
            { text = "偶要去", comment = "ou yao qu" },
        },
        ["ou ye"] = {
            { text = "欧耶", comment = "ou ye" },
            { text = "欧冶", comment = "ou ye" },
            { text = "偶也", comment = "ou ye" },
            { text = "欧也", comment = "ou ye" },
            { text = "欧叶", comment = "ou ye" },
            { text = "欧野", comment = "ou ye" },
        },
        ["ou yi"] = {
            { text = "偶一", comment = "ou yi" },
            { text = "欧意", comment = "ou yi" },
            { text = "欧艺", comment = "ou yi" },
            { text = "欧易", comment = "ou yi" },
            { text = "欧亿", comment = "ou yi" },
            { text = "欧一", comment = "ou yi" },
            { text = "欧逸", comment = "ou yi" },
        },
        ["ou yin"] = {
            { text = "讴吟", comment = "ou yin" },
        },
        ["ou ying"] = {
            { text = "欧颖", comment = "ou ying" },
            { text = "欧莹", comment = "ou ying" },
        },
        ["ou yong"] = {
            { text = "欧勇", comment = "ou yong" },
        },
        ["ou you"] = {
            { text = "偶有", comment = "ou you" },
            { text = "欧呦", comment = "ou you" },
        },
        ["ou yu"] = {
            { text = "偶遇", comment = "ou yu" },
            { text = "欧宇", comment = "ou yu" },
        },
        ["ou yuan"] = {
            { text = "欧元", comment = "ou yuan" },
            { text = "欧源", comment = "ou yuan" },
            { text = "耦园", comment = "ou yuan" },
            { text = "欧园", comment = "ou yuan" },
            { text = "瓯元", comment = "ou yuan" },
        },
        ["ou yuan qu"] = {
            { text = "欧元区", comment = "ou yuan qu" },
        },
        ["ou yue"] = {
            { text = "瓯越", comment = "ou yue" },
            { text = "欧月", comment = "ou yue" },
            { text = "欧悦", comment = "ou yue" },
        },
        ["ou yun"] = {
            { text = "偶晕", comment = "ou yun" },
            { text = "欧韵", comment = "ou yun" },
            { text = "欧孕", comment = "ou yun" },
        },
        ["ou zai"] = {
            { text = "偶在", comment = "ou zai" },
        },
        ["ou zan"] = {
            { text = "欧赞", comment = "ou zan" },
        },
        ["ou ze"] = {
            { text = "欧泽", comment = "ou ze" },
        },
        ["ou zhai"] = {
            { text = "欧债", comment = "ou zhai" },
        },
        ["ou zhan"] = {
            { text = "欧战", comment = "ou zhan" },
            { text = "欧展", comment = "ou zhan" },
        },
        ["ou zhang"] = {
            { text = "欧章", comment = "ou zhang" },
        },
        ["ou zhe"] = {
            { text = "欧哲", comment = "ou zhe" },
        },
        ["ou zhen"] = {
            { text = "欧震", comment = "ou zhen" },
        },
        ["ou zheng"] = {
            { text = "欧证", comment = "ou zheng" },
            { text = "欧正", comment = "ou zheng" },
        },
        ["ou zhi"] = {
            { text = "藕汁", comment = "ou zhi" },
            { text = "欧志", comment = "ou zhi" },
            { text = "瓯职", comment = "ou zhi" },
        },
        ["ou zhi dao"] = {
            { text = "偶知道", comment = "ou zhi dao" },
        },
        ["ou zhi shi"] = {
            { text = "偶只是", comment = "ou zhi shi" },
        },
        ["ou zhong"] = {
            { text = "欧中", comment = "ou zhong" },
        },
        ["ou zhou"] = {
            { text = "欧洲", comment = "ou zhou" },
        },
        ["ou zhu"] = {
            { text = "欧珠", comment = "ou zhu" },
            { text = "欧竹", comment = "ou zhu" },
        },
        ["ou zhu ren"] = {
            { text = "欧主任", comment = "ou zhu ren" },
        },
        ["ou zhuang"] = {
            { text = "区庄", comment = "ou zhuang" },
        },
        ["ou zhuo"] = {
            { text = "欧卓", comment = "ou zhuo" },
        },
        ["ou zi"] = {
            { text = "瓯子", comment = "ou zi" },
            { text = "欧子", comment = "ou zi" },
            { text = "欧兹", comment = "ou zi" },
            { text = "藕紫", comment = "ou zi" },
        },
        ["ou zong"] = {
            { text = "欧总", comment = "ou zong" },
        },
        ["ou zu"] = {
            { text = "偶组", comment = "ou zu" },
        },
        ["ou zuo"] = {
            { text = "偶作", comment = "ou zuo" },
        },
        ["pa ba"] = {
            { text = "爬吧", comment = "pa ba" },
        },
        ["pa bei"] = {
            { text = "怕被", comment = "pa bei" },
        },
        ["pa nan"] = {
            { text = "帕南", comment = "pa nan" },
        },
        ["pa nin"] = {
            { text = "怕您", comment = "pa nin" },
        },
        ["pa nuo"] = {
            { text = "帕诺", comment = "pa nuo" },
        },
        ["pa ta"] = {
            { text = "怕他", comment = "pa ta" },
            { text = "怕她", comment = "pa ta" },
            { text = "爬塔", comment = "pa ta" },
        },
        ["pa ti ou"] = {
            { text = "帕提欧", comment = "pa ti ou" },
            { text = "帕提欧", comment = "pa ti ou" },
        },
        ["pa ya"] = {
            { text = "怕呀", comment = "pa ya" },
        },
        ["pa yang"] = {
            { text = "扒痒", comment = "pa yang" },
        },
        ["pa yao"] = {
            { text = "怕要", comment = "pa yao" },
        },
        ["pa yo"] = {
            { text = "爬哟", comment = "pa yo" },
        },
        ["pa you"] = {
            { text = "怕有", comment = "pa you" },
        },
        ["pai a"] = {
            { text = "拍啊", comment = "pai a" },
        },
        ["pai ang"] = {
            { text = "派昂", comment = "pai ang" },
        },
        ["pai ao"] = {
            { text = "排奡", comment = "pai ao" },
        },
        ["pai bu"] = {
            { text = "排布", comment = "pai bu" },
            { text = "拍不", comment = "pai bu" },
            { text = "排不", comment = "pai bu" },
        },
        ["pai o"] = {
            { text = "拍哦", comment = "pai o" },
        },
        ["pai ou"] = {
            { text = "排偶", comment = "pai ou" },
        },
        ["pan an"] = {
            { text = "潘安", comment = "pan an" },
            { text = "磐安", comment = "pan an" },
            { text = "判案", comment = "pan an" },
        },
        ["pan wo"] = {
            { text = "盼我", comment = "pan wo" },
        },
        ["pan yu"] = {
            { text = "番禺", comment = "pan yu" },
            { text = "潘宇", comment = "pan yu" },
            { text = "潘玉", comment = "pan yu" },
            { text = "潘瑜", comment = "pan yu" },
            { text = "潘雨", comment = "pan yu" },
            { text = "潘钰", comment = "pan yu" },
        },
        ["pang a"] = {
            { text = "胖啊", comment = "pang a" },
        },
        ["pang you"] = {
            { text = "胖友", comment = "pang you" },
            { text = "旁友", comment = "pang you" },
        },
        ["pang yuan"] = {
            { text = "庞源", comment = "pang yuan" },
            { text = "庞元", comment = "pang yuan" },
        },
        ["pao a"] = {
            { text = "跑啊", comment = "pao a" },
        },
        ["pao bu"] = {
            { text = "跑步", comment = "pao bu" },
            { text = "跑不", comment = "pao bu" },
        },
        ["pao di"] = {
            { text = "刨地", comment = "pao di" },
        },
        ["pao ou"] = {
            { text = "泡藕", comment = "pao ou" },
        },
        ["pei bu"] = {
            { text = "胚布", comment = "pei bu" },
            { text = "配布", comment = "pei bu" },
            { text = "赔补", comment = "pei bu" },
        },
        ["pei ou"] = {
            { text = "配偶", comment = "pei ou" },
        },
        ["pi nei"] = {
            { text = "皮内", comment = "pi nei" },
            { text = "批内", comment = "pi nei" },
        },
        ["pi niu"] = {
            { text = "脾牛", comment = "pi niu" },
        },
        ["pi nuo"] = {
            { text = "皮诺", comment = "pi nuo" },
        },
        ["pi ta"] = {
            { text = "疲沓", comment = "pi ta" },
        },
        ["pi tai"] = {
            { text = "疲态", comment = "pi tai" },
            { text = "坯胎", comment = "pi tai" },
        },
        ["pi tou"] = {
            { text = "批头", comment = "pi tou" },
            { text = "皮头", comment = "pi tou" },
            { text = "劈头", comment = "pi tou" },
            { text = "披头", comment = "pi tou" },
            { text = "匹头", comment = "pi tou" },
            { text = "辟头", comment = "pi tou" },
            { text = "疋头", comment = "pi tou" },
        },
        ["pi tuan"] = {
            { text = "批团", comment = "pi tuan" },
        },
        ["pi tuo"] = {
            { text = "皮拖", comment = "pi tuo" },
        },
        ["pin di"] = {
            { text = "品第", comment = "pin di" },
        },
        ["pin wo"] = {
            { text = "品渥", comment = "pin wo" },
        },
        ["pin yu"] = {
            { text = "频域", comment = "pin yu" },
        },
        ["ping a"] = {
            { text = "平啊", comment = "ping a" },
        },
        ["ping ai"] = {
            { text = "平爱", comment = "ping ai" },
        },
        ["ping bu"] = {
            { text = "平布", comment = "ping bu" },
            { text = "平步", comment = "ping bu" },
        },
        ["ping huai"] = {
            { text = "屏坏", comment = "ping huai" },
        },
        ["ping ri"] = {
            { text = "平日", comment = "ping ri" },
        },
        ["ping wo"] = {
            { text = "凭我", comment = "ping wo" },
            { text = "平卧", comment = "ping wo" },
        },
        ["ping xu"] = {
            { text = "凭虚", comment = "ping xu" },
        },
        ["po huai"] = {
            { text = "破坏", comment = "po huai" },
        },
        ["po ri"] = {
            { text = "破日", comment = "po ri" },
        },
        ["pu ao"] = {
            { text = "普奥", comment = "pu ao" },
        },
        ["pu bu"] = {
            { text = "瀑布", comment = "pu bu" },
            { text = "普布", comment = "pu bu" },
            { text = "铺布", comment = "pu bu" },
        },
        ["pu fo"] = {
            { text = "普佛", comment = "pu fo" },
        },
        ["pu ou"] = {
            { text = "浦瓯", comment = "pu ou" },
        },
        ["qi dan"] = {
            { text = "契丹", comment = "qi dan" },
            { text = "起单", comment = "qi dan" },
            { text = "弃单", comment = "qi dan" },
            { text = "气弹", comment = "qi dan" },
            { text = "齐丹", comment = "qi dan" },
            { text = "奇蛋", comment = "qi dan" },
            { text = "气蛋", comment = "qi dan" },
            { text = "七丹", comment = "qi dan" },
            { text = "齐单", comment = "qi dan" },
            { text = "岂但", comment = "qi dan" },
            { text = "奇弹", comment = "qi dan" },
        },
        ["qi de wo"] = {
            { text = "气得我", comment = "qi de wo" },
        },
        ["qi dou"] = {
            { text = "起痘", comment = "qi dou" },
            { text = "奇豆", comment = "qi dou" },
        },
        ["qi duo"] = {
            { text = "奇多", comment = "qi duo" },
            { text = "七朵", comment = "qi duo" },
            { text = "奇朵", comment = "qi duo" },
        },
        ["qi e"] = {
            { text = "企鹅", comment = "qi e" },
        },
        ["qi e dao"] = {
            { text = "企鹅岛", comment = "qi e dao" },
        },
        ["qi e hao"] = {
            { text = "企鹅号", comment = "qi e hao" },
        },
        ["qi e ren"] = {
            { text = "企鹅人", comment = "qi e ren" },
        },
        ["qi e rou"] = {
            { text = "企鹅肉", comment = "qi e rou" },
        },
        ["qi e wang"] = {
            { text = "企鹅王", comment = "qi e wang" },
        },
        ["qi e wo"] = {
            { text = "企鹅窝", comment = "qi e wo" },
        },
        ["qi hua an"] = {
            { text = "企划案", comment = "qi hua an" },
        },
        ["qi huai"] = {
            { text = "气坏", comment = "qi huai" },
        },
        ["qi na"] = {
            { text = "齐纳", comment = "qi na" },
            { text = "齐娜", comment = "qi na" },
            { text = "祁娜", comment = "qi na" },
            { text = "亓那", comment = "qi na" },
        },
        ["qi na di"] = {
            { text = "齐纳蒂", comment = "qi na di" },
        },
        ["qi nai"] = {
            { text = "七奈", comment = "qi nai" },
        },
        ["qi nan"] = {
            { text = "奇楠", comment = "qi nan" },
            { text = "齐楠", comment = "qi nan" },
        },
        ["qi nei"] = {
            { text = "期内", comment = "qi nei" },
            { text = "气馁", comment = "qi nei" },
            { text = "其内", comment = "qi nei" },
        },
        ["qi nie"] = {
            { text = "期镍", comment = "qi nie" },
        },
        ["qi niu"] = {
            { text = "骑牛", comment = "qi niu" },
            { text = "七牛", comment = "qi niu" },
            { text = "启牛", comment = "qi niu" },
        },
        ["qi nuan"] = {
            { text = "奇暖", comment = "qi nuan" },
            { text = "汽暖", comment = "qi nuan" },
        },
        ["qi nuo"] = {
            { text = "奇诺", comment = "qi nuo" },
            { text = "淇诺", comment = "qi nuo" },
            { text = "启诺", comment = "qi nuo" },
        },
        ["qi ran"] = {
            { text = "凄然", comment = "qi ran" },
            { text = "奇然", comment = "qi ran" },
        },
        ["qi ri"] = {
            { text = "七日", comment = "qi ri" },
            { text = "期日", comment = "qi ri" },
        },
        ["qi ta"] = {
            { text = "其他", comment = "qi ta" },
            { text = "其它", comment = "qi ta" },
            { text = "气他", comment = "qi ta" },
            { text = "起塔", comment = "qi ta" },
        },
        ["qi tai"] = {
            { text = "奇台", comment = "qi tai" },
            { text = "气态", comment = "qi tai" },
            { text = "七台", comment = "qi tai" },
            { text = "旗台", comment = "qi tai" },
            { text = "启泰", comment = "qi tai" },
            { text = "齐泰", comment = "qi tai" },
            { text = "气胎", comment = "qi tai" },
            { text = "企泰", comment = "qi tai" },
        },
        ["qi tan"] = {
            { text = "奇谈", comment = "qi tan" },
            { text = "奇谭", comment = "qi tan" },
            { text = "棋坛", comment = "qi tan" },
            { text = "棋谭", comment = "qi tan" },
            { text = "奇弹", comment = "qi tan" },
        },
        ["qi tao"] = {
            { text = "乞讨", comment = "qi tao" },
            { text = "齐套", comment = "qi tao" },
            { text = "七套", comment = "qi tao" },
            { text = "齐涛", comment = "qi tao" },
            { text = "启涛", comment = "qi tao" },
            { text = "祁涛", comment = "qi tao" },
            { text = "其涛", comment = "qi tao" },
        },
        ["qi tie"] = {
            { text = "脐贴", comment = "qi tie" },
        },
        ["qi tou"] = {
            { text = "起头", comment = "qi tou" },
            { text = "气头", comment = "qi tou" },
            { text = "起投", comment = "qi tou" },
            { text = "齐头", comment = "qi tou" },
            { text = "岐头", comment = "qi tou" },
            { text = "旗头", comment = "qi tou" },
        },
        ["qi tuan"] = {
            { text = "气团", comment = "qi tuan" },
        },
        ["qi tuo"] = {
            { text = "起坨", comment = "qi tuo" },
            { text = "启拓", comment = "qi tuo" },
        },
        ["qi wai"] = {
            { text = "其外", comment = "qi wai" },
        },
        ["qi wan"] = {
            { text = "七万", comment = "qi wan" },
            { text = "起晚", comment = "qi wan" },
            { text = "凄婉", comment = "qi wan" },
            { text = "起湾", comment = "qi wan" },
            { text = "柒万", comment = "qi wan" },
        },
        ["qi wei"] = {
            { text = "气味", comment = "qi wei" },
            { text = "戚薇", comment = "qi wei" },
            { text = "企微", comment = "qi wei" },
            { text = "七位", comment = "qi wei" },
            { text = "齐伟", comment = "qi wei" },
            { text = "其为", comment = "qi wei" },
            { text = "旗委", comment = "qi wei" },
            { text = "奇伟", comment = "qi wei" },
            { text = "七味", comment = "qi wei" },
            { text = "祁伟", comment = "qi wei" },
            { text = "七维", comment = "qi wei" },
            { text = "启维", comment = "qi wei" },
            { text = "期为", comment = "qi wei" },
            { text = "齐威", comment = "qi wei" },
            { text = "七尾", comment = "qi wei" },
            { text = "奇威", comment = "qi wei" },
            { text = "奇味", comment = "qi wei" },
            { text = "启威", comment = "qi wei" },
            { text = "七圩", comment = "qi wei" },
            { text = "其伟", comment = "qi wei" },
            { text = "其味", comment = "qi wei" },
            { text = "颀伟", comment = "qi wei" },
            { text = "启伟", comment = "qi wei" },
        },
        ["qia ta"] = {
            { text = "掐他", comment = "qia ta" },
        },
        ["qia tan"] = {
            { text = "洽谈", comment = "qia tan" },
        },
        ["qia tou"] = {
            { text = "掐头", comment = "qia tou" },
        },
        ["qian ao"] = {
            { text = "钱傲", comment = "qian ao" },
        },
        ["qian bu"] = {
            { text = "前部", comment = "qian bu" },
            { text = "钱不", comment = "qian bu" },
            { text = "浅部", comment = "qian bu" },
            { text = "嵌补", comment = "qian bu" },
        },
        ["qian die"] = {
            { text = "千蝶", comment = "qian die" },
            { text = "前碟", comment = "qian die" },
        },
        ["qian e ye"] = {
            { text = "前额叶", comment = "qian e ye" },
        },
        ["qian fo"] = {
            { text = "千佛", comment = "qian fo" },
        },
        ["qian ou"] = {
            { text = "千欧", comment = "qian ou" },
        },
        ["qiang a"] = {
            { text = "强啊", comment = "qiang a" },
            { text = "抢啊", comment = "qiang a" },
        },
        ["qiang an"] = {
            { text = "羟胺", comment = "qiang an" },
            { text = "强安", comment = "qiang an" },
        },
        ["qiang bu"] = {
            { text = "墙布", comment = "qiang bu" },
            { text = "抢不", comment = "qiang bu" },
        },
        ["qie"] = {
            { text = "切", comment = "qie" },
            { text = "且", comment = "qie" },
            { text = "妾", comment = "qie" },
            { text = "窃", comment = "qie" },
            { text = "茄", comment = "qie" },
            { text = "砌", comment = "qie" },
            { text = "怯", comment = "qie" },
            { text = "锲", comment = "qie" },
            { text = "郄", comment = "qie" },
            { text = "挈", comment = "qie" },
            { text = "惬", comment = "qie" },
            { text = "箧", comment = "qie" },
            { text = "伽", comment = "qie" },
            { text = "癿", comment = "qie" },
            { text = "趄", comment = "qie" },
            { text = "慊", comment = "qie" },
        },
        ["qie an"] = {
            { text = "窃案", comment = "qie an" },
        },
        ["qie bu"] = {
            { text = "且不", comment = "qie bu" },
        },
        ["qie dao"] = {
            { text = "切刀", comment = "qie dao" },
            { text = "切到", comment = "qie dao" },
            { text = "切岛", comment = "qie dao" },
        },
        ["qie duo"] = {
            { text = "窃夺", comment = "qie duo" },
        },
        ["qie hao"] = {
            { text = "切好", comment = "qie hao" },
            { text = "切号", comment = "qie hao" },
        },
        ["qie ren"] = {
            { text = "切人", comment = "qie ren" },
        },
        ["qie rou"] = {
            { text = "切肉", comment = "qie rou" },
        },
        ["qie wang"] = {
            { text = "茄王", comment = "qie wang" },
        },
        ["qie wo"] = {
            { text = "切沃", comment = "qie wo" },
            { text = "切我", comment = "qie wo" },
        },
        ["qin a"] = {
            { text = "亲啊", comment = "qin a" },
        },
        ["qin ai"] = {
            { text = "亲爱", comment = "qin ai" },
        },
        ["qin an"] = {
            { text = "秦安", comment = "qin an" },
        },
        ["qin di"] = {
            { text = "亲弟", comment = "qin di" },
            { text = "琴帝", comment = "qin di" },
            { text = "擒敌", comment = "qin di" },
        },
        ["qin fei"] = {
            { text = "秦飞", comment = "qin fei" },
            { text = "秦菲", comment = "qin fei" },
            { text = "覃飞", comment = "qin fei" },
            { text = "寝肥", comment = "qin fei" },
        },
        ["qin huai"] = {
            { text = "秦淮", comment = "qin huai" },
            { text = "覃怀", comment = "qin huai" },
        },
        ["qin ri"] = {
            { text = "琴日", comment = "qin ri" },
            { text = "亲日", comment = "qin ri" },
        },
        ["qin wo"] = {
            { text = "亲我", comment = "qin wo" },
        },
        ["qin xu"] = {
            { text = "秦旭", comment = "qin xu" },
        },
        ["qin ye"] = {
            { text = "勤业", comment = "qin ye" },
            { text = "禽业", comment = "qin ye" },
            { text = "琴叶", comment = "qin ye" },
            { text = "秦爷", comment = "qin ye" },
        },
        ["qin yu"] = {
            { text = "勤于", comment = "qin yu" },
            { text = "秦宇", comment = "qin yu" },
            { text = "秦玉", comment = "qin yu" },
            { text = "秦雨", comment = "qin yu" },
            { text = "秦羽", comment = "qin yu" },
            { text = "秦瑜", comment = "qin yu" },
            { text = "覃宇", comment = "qin yu" },
            { text = "秦屿", comment = "qin yu" },
            { text = "秦钰", comment = "qin yu" },
            { text = "秦煜", comment = "qin yu" },
            { text = "亲鱼", comment = "qin yu" },
            { text = "秦语", comment = "qin yu" },
        },
        ["qing a"] = {
            { text = "情啊", comment = "qing a" },
        },
        ["qing ai"] = {
            { text = "情爱", comment = "qing ai" },
        },
        ["qing an"] = {
            { text = "请安", comment = "qing an" },
            { text = "请按", comment = "qing an" },
            { text = "庆安", comment = "qing an" },
            { text = "清安", comment = "qing an" },
            { text = "轻安", comment = "qing an" },
        },
        ["qing ao"] = {
            { text = "青奥", comment = "qing ao" },
        },
        ["qing bu"] = {
            { text = "清补", comment = "qing bu" },
            { text = "请不", comment = "qing bu" },
            { text = "请补", comment = "qing bu" },
            { text = "清布", comment = "qing bu" },
            { text = "青布", comment = "qing bu" },
        },
        ["qing fo"] = {
            { text = "清佛", comment = "qing fo" },
        },
        ["qing huai"] = {
            { text = "情怀", comment = "qing huai" },
        },
        ["qing ri"] = {
            { text = "晴日", comment = "qing ri" },
        },
        ["qing shu yin"] = {
            { text = "青叔音", comment = "qing shu yin" },
        },
        ["qing shui yu"] = {
            { text = "清水鱼", comment = "qing shui yu" },
        },
        ["qing wo"] = {
            { text = "请我", comment = "qing wo" },
        },
        ["qing xu"] = {
            { text = "情绪", comment = "qing xu" },
            { text = "清徐", comment = "qing xu" },
            { text = "清虚", comment = "qing xu" },
        },
        ["qing ye"] = {
            { text = "青叶", comment = "qing ye" },
            { text = "清液", comment = "qing ye" },
            { text = "清夜", comment = "qing ye" },
            { text = "清野", comment = "qing ye" },
            { text = "青野", comment = "qing ye" },
            { text = "庆业", comment = "qing ye" },
        },
        ["qiong a"] = {
            { text = "穷啊", comment = "qiong a" },
        },
        ["qiu ai"] = {
            { text = "求爱", comment = "qiu ai" },
            { text = "邱隘", comment = "qiu ai" },
        },
        ["qiu an"] = {
            { text = "秋安", comment = "qiu an" },
        },
        ["qiu bu"] = {
            { text = "求不", comment = "qiu bu" },
            { text = "球部", comment = "qiu bu" },
            { text = "求补", comment = "qiu bu" },
            { text = "邱部", comment = "qiu bu" },
        },
        ["qiu di"] = {
            { text = "邱迪", comment = "qiu di" },
        },
        ["qiu ou"] = {
            { text = "求偶", comment = "qiu ou" },
        },
        ["qu bu"] = {
            { text = "去不", comment = "qu bu" },
            { text = "去补", comment = "qu bu" },
            { text = "区部", comment = "qu bu" },
            { text = "趣步", comment = "qu bu" },
        },
        ["qu dai"] = {
            { text = "取代", comment = "qu dai" },
            { text = "去带", comment = "qu dai" },
            { text = "区代", comment = "qu dai" },
        },
        ["qu de"] = {
            { text = "去的", comment = "qu de" },
            { text = "取得", comment = "qu de" },
            { text = "取的", comment = "qu de" },
            { text = "区的", comment = "qu de" },
            { text = "去得", comment = "qu de" },
            { text = "佢地", comment = "qu de" },
        },
        ["qu dou"] = {
            { text = "祛痘", comment = "qu dou" },
            { text = "去痘", comment = "qu dou" },
            { text = "趣豆", comment = "qu dou" },
        },
        ["qu duan"] = {
            { text = "区段", comment = "qu duan" },
            { text = "曲断", comment = "qu duan" },
        },
        ["qu duo"] = {
            { text = "趣多", comment = "qu duo" },
        },
        ["qu huai"] = {
            { text = "龋坏", comment = "qu huai" },
        },
        ["qu na a"] = {
            { text = "去哪啊", comment = "qu na a" },
        },
        ["qu nan"] = {
            { text = "渠南", comment = "qu nan" },
            { text = "曲楠", comment = "qu nan" },
        },
        ["qu nei"] = {
            { text = "区内", comment = "qu nei" },
        },
        ["qu nin"] = {
            { text = "去您", comment = "qu nin" },
        },
        ["qu ou"] = {
            { text = "去耦", comment = "qu ou" },
        },
        ["qu ri"] = {
            { text = "去日", comment = "qu ri" },
        },
        ["qu ta"] = {
            { text = "娶她", comment = "qu ta" },
            { text = "去他", comment = "qu ta" },
            { text = "去她", comment = "qu ta" },
        },
        ["quan bu"] = {
            { text = "全部", comment = "quan bu" },
            { text = "全不", comment = "quan bu" },
        },
        ["quan huai"] = {
            { text = "全坏", comment = "quan huai" },
        },
        ["quan ou"] = {
            { text = "全欧", comment = "quan ou" },
        },
        ["quan ri"] = {
            { text = "全日", comment = "quan ri" },
        },
        ["que ai"] = {
            { text = "缺爱", comment = "que ai" },
        },
        ["que bu"] = {
            { text = "却不", comment = "que bu" },
            { text = "却步", comment = "que bu" },
        },
        ["que e"] = {
            { text = "缺额", comment = "que e" },
        },
        ["que wo"] = {
            { text = "缺我", comment = "que wo" },
        },
        ["que xu"] = {
            { text = "确需", comment = "que xu" },
        },
        ["qun an"] = {
            { text = "群安", comment = "qun an" },
        },
        ["qun bu"] = {
            { text = "群补", comment = "qun bu" },
        },
        ["qun di"] = {
            { text = "裙底", comment = "qun di" },
        },
        ["qun fa"] = {
            { text = "群发", comment = "qun fa" },
            { text = "群法", comment = "qun fa" },
        },
        ["qun ou"] = {
            { text = "群殴", comment = "qun ou" },
        },
        ["qun yu"] = {
            { text = "群宇", comment = "qun yu" },
        },
        ["ran"] = {
            { text = "然", comment = "ran" },
            { text = "染", comment = "ran" },
            { text = "燃", comment = "ran" },
            { text = "冉", comment = "ran" },
            { text = "苒", comment = "ran" },
            { text = "髯", comment = "ran" },
            { text = "蚺", comment = "ran" },
            { text = "䎃", comment = "ran" },
        },
        ["ran bao"] = {
            { text = "燃爆", comment = "ran bao" },
        },
        ["ran li"] = {
            { text = "冉丽", comment = "ran li" },
            { text = "然利", comment = "ran li" },
        },
        ["ran tang"] = {
            { text = "染烫", comment = "ran tang" },
        },
        ["rang"] = {
            { text = "让", comment = "rang" },
            { text = "嚷", comment = "rang" },
            { text = "壤", comment = "rang" },
            { text = "瓤", comment = "rang" },
            { text = "攘", comment = "rang" },
            { text = "禳", comment = "rang" },
            { text = "穰", comment = "rang" },
            { text = "蘘", comment = "rang" },
            { text = "瀼", comment = "rang" },
            { text = "儴", comment = "rang" },
            { text = "𬙋", comment = "rang" },
        },
        ["rang bu"] = {
            { text = "让步", comment = "rang bu" },
        },
        ["rang ou"] = {
            { text = "让偶", comment = "rang ou" },
        },
        ["rao"] = {
            { text = "绕", comment = "rao" },
            { text = "饶", comment = "rao" },
            { text = "扰", comment = "rao" },
            { text = "娆", comment = "rao" },
            { text = "荛", comment = "rao" },
            { text = "桡", comment = "rao" },
        },
        ["re"] = {
            { text = "热", comment = "re" },
            { text = "惹", comment = "re" },
            { text = "若", comment = "re" },
            { text = "喏", comment = "re" },
        },
        ["re a"] = {
            { text = "热啊", comment = "re a" },
        },
        ["re ai"] = {
            { text = "热爱", comment = "re ai" },
        },
        ["re ang"] = {
            { text = "热昂", comment = "re ang" },
        },
        ["re bu"] = {
            { text = "热不", comment = "re bu" },
            { text = "热补", comment = "re bu" },
        },
        ["re dian bu"] = {
            { text = "热电部", comment = "re dian bu" },
        },
        ["re dian ou"] = {
            { text = "热电偶", comment = "re dian ou" },
        },
        ["re na"] = {
            { text = "热娜", comment = "re na" },
        },
        ["re nai"] = {
            { text = "热奶", comment = "re nai" },
        },
        ["re ne"] = {
            { text = "热呢", comment = "re ne" },
        },
        ["re nei"] = {
            { text = "热内", comment = "re nei" },
        },
        ["re nin"] = {
            { text = "惹您", comment = "re nin" },
        },
        ["re nuan"] = {
            { text = "热暖", comment = "re nuan" },
        },
        ["re nuo"] = {
            { text = "热诺", comment = "re nuo" },
        },
        ["re ou"] = {
            { text = "热偶", comment = "re ou" },
        },
        ["re wo"] = {
            { text = "惹我", comment = "re wo" },
        },
        ["re ye"] = {
            { text = "热液", comment = "re ye" },
        },
        ["ren"] = {
            { text = "人", comment = "ren" },
            { text = "任", comment = "ren" },
            { text = "认", comment = "ren" },
            { text = "忍", comment = "ren" },
            { text = "仁", comment = "ren" },
            { text = "刃", comment = "ren" },
            { text = "韧", comment = "ren" },
            { text = "壬", comment = "ren" },
            { text = "亻", comment = "ren" },
            { text = "仞", comment = "ren" },
            { text = "妊", comment = "ren" },
            { text = "纫", comment = "ren" },
            { text = "荏", comment = "ren" },
            { text = "稔", comment = "ren" },
            { text = "轫", comment = "ren" },
            { text = "衽", comment = "ren" },
            { text = "饪", comment = "ren" },
            { text = "讱", comment = "ren" },
            { text = "纴", comment = "ren" },
        },
        ["ren a"] = {
            { text = "人啊", comment = "ren a" },
        },
        ["ren ai"] = {
            { text = "仁爱", comment = "ren ai" },
            { text = "人爱", comment = "ren ai" },
        },
        ["ren bu"] = {
            { text = "人不", comment = "ren bu" },
            { text = "任部", comment = "ren bu" },
            { text = "仁布", comment = "ren bu" },
        },
        ["ren bu shi"] = {
            { text = "人不是", comment = "ren bu shi" },
            { text = "认不是", comment = "ren bu shi" },
        },
        ["ren di"] = {
            { text = "人地", comment = "ren di" },
            { text = "人哋", comment = "ren di" },
            { text = "任迪", comment = "ren di" },
            { text = "仁弟", comment = "ren di" },
        },
        ["ren e"] = {
            { text = "人哦", comment = "ren e" },
        },
        ["ren huai"] = {
            { text = "仁怀", comment = "ren huai" },
        },
        ["ren ou"] = {
            { text = "人偶", comment = "ren ou" },
        },
        ["ren ou shi"] = {
            { text = "人偶师", comment = "ren ou shi" },
        },
        ["ren ri"] = {
            { text = "人日", comment = "ren ri" },
        },
        ["ren wo"] = {
            { text = "任我", comment = "ren wo" },
            { text = "认我", comment = "ren wo" },
        },
        ["ren xu"] = {
            { text = "壬戌", comment = "ren xu" },
            { text = "任旭", comment = "ren xu" },
        },
        ["ren yu"] = {
            { text = "人鱼", comment = "ren yu" },
            { text = "人与", comment = "ren yu" },
            { text = "任宇", comment = "ren yu" },
            { text = "人语", comment = "ren yu" },
            { text = "任玉", comment = "ren yu" },
            { text = "人欲", comment = "ren yu" },
            { text = "任雨", comment = "ren yu" },
            { text = "仁宇", comment = "ren yu" },
        },
        ["ri"] = {
            { text = "日", comment = "ri" },
            { text = "驲", comment = "ri" },
        },
        ["ri a"] = {
            { text = "日啊", comment = "ri a" },
            { text = "日啊", comment = "ri a" },
        },
        ["ri ai"] = {
            { text = "日爱", comment = "ri ai" },
        },
        ["ri an"] = {
            { text = "日安", comment = "ri an" },
            { text = "日安", comment = "ri an" },
        },
        ["ri ang"] = {
            { text = "日昂", comment = "ri ang" },
            { text = "日昂", comment = "ri ang" },
        },
        ["ri ao"] = {
            { text = "日奥", comment = "ri ao" },
            { text = "日奥", comment = "ri ao" },
        },
        ["ri ba"] = {
            { text = "日吧", comment = "ri ba" },
        },
        ["ri bao"] = {
            { text = "日报", comment = "ri bao" },
            { text = "日包", comment = "ri bao" },
            { text = "日宝", comment = "ri bao" },
        },
        ["ri bei"] = {
            { text = "日被", comment = "ri bei" },
            { text = "日被", comment = "ri bei" },
        },
        ["ri biao"] = {
            { text = "日表", comment = "ri biao" },
            { text = "日标", comment = "ri biao" },
        },
        ["ri bu"] = {
            { text = "日不", comment = "ri bu" },
        },
        ["ri cai"] = {
            { text = "日彩", comment = "ri cai" },
            { text = "日财", comment = "ri cai" },
            { text = "日才", comment = "ri cai" },
        },
        ["ri che"] = {
            { text = "日车", comment = "ri che" },
        },
        ["ri cheng"] = {
            { text = "日程", comment = "ri cheng" },
            { text = "日成", comment = "ri cheng" },
            { text = "日称", comment = "ri cheng" },
        },
        ["ri chu"] = {
            { text = "日出", comment = "ri chu" },
        },
        ["ri chuan"] = {
            { text = "日川", comment = "ri chuan" },
            { text = "日船", comment = "ri chuan" },
        },
        ["ri chun"] = {
            { text = "日春", comment = "ri chun" },
        },
        ["ri dan"] = {
            { text = "日单", comment = "ri dan" },
        },
        ["ri dang"] = {
            { text = "日当", comment = "ri dang" },
        },
        ["ri dao"] = {
            { text = "日岛", comment = "ri dao" },
            { text = "日到", comment = "ri dao" },
        },
        ["ri de"] = {
            { text = "日的", comment = "ri de" },
            { text = "日德", comment = "ri de" },
        },
        ["ri di"] = {
            { text = "日第", comment = "ri di" },
            { text = "日第", comment = "ri di" },
        },
        ["ri dian"] = {
            { text = "日电", comment = "ri dian" },
        },
        ["ri dong"] = {
            { text = "日东", comment = "ri dong" },
        },
        ["ri e"] = {
            { text = "日俄", comment = "ri e" },
            { text = "日额", comment = "ri e" },
        },
        ["ri en"] = {
            { text = "日恩", comment = "ri en" },
            { text = "日恩", comment = "ri en" },
        },
        ["ri er"] = {
            { text = "日珥", comment = "ri er" },
        },
        ["ri fang"] = {
            { text = "日方", comment = "ri fang" },
        },
        ["ri fei"] = {
            { text = "日飞", comment = "ri fei" },
        },
        ["ri feng"] = {
            { text = "日丰", comment = "ri feng" },
            { text = "日风", comment = "ri feng" },
        },
        ["ri fu"] = {
            { text = "日服", comment = "ri fu" },
            { text = "日付", comment = "ri fu" },
            { text = "日富", comment = "ri fu" },
        },
        ["ri gang"] = {
            { text = "日钢", comment = "ri gang" },
        },
        ["ri gao"] = {
            { text = "日高", comment = "ri gao" },
        },
        ["ri ge"] = {
            { text = "日哥", comment = "ri ge" },
        },
        ["ri gong"] = {
            { text = "日工", comment = "ri gong" },
            { text = "日供", comment = "ri gong" },
            { text = "日共", comment = "ri gong" },
        },
        ["ri gu"] = {
            { text = "日股", comment = "ri gu" },
            { text = "日谷", comment = "ri gu" },
        },
        ["ri guang"] = {
            { text = "日光", comment = "ri guang" },
        },
        ["ri gui"] = {
            { text = "日晷", comment = "ri gui" },
            { text = "日鬼", comment = "ri gui" },
            { text = "日规", comment = "ri gui" },
        },
        ["ri guo"] = {
            { text = "日过", comment = "ri guo" },
        },
        ["ri hai"] = {
            { text = "日海", comment = "ri hai" },
        },
        ["ri he"] = {
            { text = "日和", comment = "ri he" },
            { text = "日禾", comment = "ri he" },
        },
        ["ri hu"] = {
            { text = "日湖", comment = "ri hu" },
        },
        ["ri hua"] = {
            { text = "日化", comment = "ri hua" },
            { text = "日华", comment = "ri hua" },
        },
        ["ri hua bu"] = {
            { text = "日化部", comment = "ri hua bu" },
        },
        ["ri huo"] = {
            { text = "日活", comment = "ri huo" },
            { text = "日货", comment = "ri huo" },
            { text = "日火", comment = "ri huo" },
            { text = "日或", comment = "ri huo" },
        },
        ["ri ji"] = {
            { text = "日记", comment = "ri ji" },
            { text = "日机", comment = "ri ji" },
            { text = "日基", comment = "ri ji" },
            { text = "日及", comment = "ri ji" },
        },
        ["ri jian"] = {
            { text = "日渐", comment = "ri jian" },
            { text = "日间", comment = "ri jian" },
            { text = "日检", comment = "ri jian" },
            { text = "日建", comment = "ri jian" },
            { text = "日见", comment = "ri jian" },
        },
        ["ri jiang"] = {
            { text = "日将", comment = "ri jiang" },
        },
        ["ri jiao"] = {
            { text = "日胶", comment = "ri jiao" },
        },
        ["ri jie"] = {
            { text = "日结", comment = "ri jie" },
        },
        ["ri jin"] = {
            { text = "日进", comment = "ri jin" },
            { text = "日金", comment = "ri jin" },
        },
        ["ri jiu"] = {
            { text = "日久", comment = "ri jiu" },
            { text = "日灸", comment = "ri jiu" },
            { text = "日就", comment = "ri jiu" },
        },
        ["ri ju"] = {
            { text = "日剧", comment = "ri ju" },
        },
        ["ri jun"] = {
            { text = "日均", comment = "ri jun" },
            { text = "日军", comment = "ri jun" },
        },
        ["ri ka"] = {
            { text = "日卡", comment = "ri ka" },
        },
        ["ri kan"] = {
            { text = "日刊", comment = "ri kan" },
        },
        ["ri kou"] = {
            { text = "日寇", comment = "ri kou" },
        },
        ["ri kuan"] = {
            { text = "日款", comment = "ri kuan" },
        },
        ["ri kuang"] = {
            { text = "日况", comment = "ri kuang" },
            { text = "日矿", comment = "ri kuang" },
        },
        ["ri lai"] = {
            { text = "日来", comment = "ri lai" },
        },
        ["ri le"] = {
            { text = "日了", comment = "ri le" },
        },
        ["ri li"] = {
            { text = "日历", comment = "ri li" },
            { text = "日立", comment = "ri li" },
            { text = "日丽", comment = "ri li" },
            { text = "日里", comment = "ri li" },
            { text = "日利", comment = "ri li" },
            { text = "日砾", comment = "ri li" },
        },
        ["ri lian"] = {
            { text = "日联", comment = "ri lian" },
        },
        ["ri liang"] = {
            { text = "日粮", comment = "ri liang" },
        },
        ["ri liao"] = {
            { text = "日料", comment = "ri liao" },
        },
        ["ri long"] = {
            { text = "日龙", comment = "ri long" },
            { text = "日隆", comment = "ri long" },
        },
        ["ri lu"] = {
            { text = "日禄", comment = "ri lu" },
        },
        ["ri ma"] = {
            { text = "日嘛", comment = "ri ma" },
            { text = "日吗", comment = "ri ma" },
            { text = "日妈", comment = "ri ma" },
            { text = "日麻", comment = "ri ma" },
        },
        ["ri mian"] = {
            { text = "日冕", comment = "ri mian" },
        },
        ["ri mu"] = {
            { text = "日暮", comment = "ri mu" },
        },
        ["ri na"] = {
            { text = "日娜", comment = "ri na" },
        },
        ["ri ni"] = {
            { text = "日你", comment = "ri ni" },
        },
        ["ri nv"] = {
            { text = "日女", comment = "ri nv" },
        },
        ["ri o"] = {
            { text = "日哦", comment = "ri o" },
            { text = "日哦", comment = "ri o" },
        },
        ["ri ou"] = {
            { text = "日欧", comment = "ri ou" },
        },
        ["ri pan"] = {
            { text = "日盘", comment = "ri pan" },
        },
        ["ri ping"] = {
            { text = "日评", comment = "ri ping" },
        },
        ["ri qi"] = {
            { text = "日期", comment = "ri qi" },
            { text = "日起", comment = "ri qi" },
            { text = "日企", comment = "ri qi" },
        },
        ["ri qian"] = {
            { text = "日前", comment = "ri qian" },
            { text = "日签", comment = "ri qian" },
        },
        ["ri qiang"] = {
            { text = "日强", comment = "ri qiang" },
        },
        ["ri qing"] = {
            { text = "日清", comment = "ri qing" },
        },
        ["ri ri"] = {
            { text = "日日", comment = "ri ri" },
        },
        ["ri rong"] = {
            { text = "日荣", comment = "ri rong" },
        },
        ["ri shan"] = {
            { text = "日山", comment = "ri shan" },
            { text = "日善", comment = "ri shan" },
            { text = "日单", comment = "ri shan" },
        },
        ["ri shang"] = {
            { text = "日上", comment = "ri shang" },
            { text = "日商", comment = "ri shang" },
            { text = "日尚", comment = "ri shang" },
        },
        ["ri sheng"] = {
            { text = "日升", comment = "ri sheng" },
            { text = "日盛", comment = "ri sheng" },
            { text = "日生", comment = "ri sheng" },
            { text = "日昇", comment = "ri sheng" },
            { text = "日晟", comment = "ri sheng" },
            { text = "日胜", comment = "ri sheng" },
        },
        ["ri shi"] = {
            { text = "日式", comment = "ri shi" },
            { text = "日食", comment = "ri shi" },
            { text = "日蚀", comment = "ri shi" },
            { text = "日是", comment = "ri shi" },
            { text = "日时", comment = "ri shi" },
            { text = "日石", comment = "ri shi" },
            { text = "日世", comment = "ri shi" },
        },
        ["ri shi qing"] = {
            { text = "日事清", comment = "ri shi qing" },
        },
        ["ri shou"] = {
            { text = "日收", comment = "ri shou" },
        },
        ["ri shu"] = {
            { text = "日数", comment = "ri shu" },
        },
        ["ri shu ju"] = {
            { text = "日数据", comment = "ri shu ju" },
        },
        ["ri shui"] = {
            { text = "日水", comment = "ri shui" },
        },
        ["ri shuo"] = {
            { text = "日说", comment = "ri shuo" },
        },
        ["ri si"] = {
            { text = "日死", comment = "ri si" },
        },
        ["ri song"] = {
            { text = "日松", comment = "ri song" },
        },
        ["ri ta"] = {
            { text = "日他", comment = "ri ta" },
        },
        ["ri tai"] = {
            { text = "日泰", comment = "ri tai" },
            { text = "日泰", comment = "ri tai" },
        },
        ["ri tan"] = {
            { text = "日坛", comment = "ri tan" },
        },
        ["ri tao"] = {
            { text = "日淘", comment = "ri tao" },
        },
        ["ri te"] = {
            { text = "日特", comment = "ri te" },
        },
        ["ri tie"] = {
            { text = "日铁", comment = "ri tie" },
        },
        ["ri tou"] = {
            { text = "日头", comment = "ri tou" },
        },
        ["ri tuo"] = {
            { text = "日托", comment = "ri tuo" },
        },
        ["ri wa"] = {
            { text = "日瓦", comment = "ri wa" },
        },
        ["ri wang"] = {
            { text = "日旺", comment = "ri wang" },
        },
        ["ri wei"] = {
            { text = "日威", comment = "ri wei" },
            { text = "日为", comment = "ri wei" },
        },
        ["ri wen"] = {
            { text = "日文", comment = "ri wen" },
        },
        ["ri wen ming"] = {
            { text = "日文名", comment = "ri wen ming" },
        },
        ["ri xi"] = {
            { text = "日系", comment = "ri xi" },
            { text = "日息", comment = "ri xi" },
            { text = "日夕", comment = "ri xi" },
        },
        ["ri xia"] = {
            { text = "日下", comment = "ri xia" },
        },
        ["ri xian"] = {
            { text = "日线", comment = "ri xian" },
        },
        ["ri xiang"] = {
            { text = "日向", comment = "ri xiang" },
            { text = "日翔", comment = "ri xiang" },
        },
        ["ri xiao"] = {
            { text = "日销", comment = "ri xiao" },
        },
        ["ri xiao xi"] = {
            { text = "日消息", comment = "ri xiao xi" },
        },
        ["ri xie"] = {
            { text = "日写", comment = "ri xie" },
        },
        ["ri xin"] = {
            { text = "日新", comment = "ri xin" },
            { text = "日薪", comment = "ri xin" },
            { text = "日鑫", comment = "ri xin" },
            { text = "日信", comment = "ri xin" },
            { text = "日欣", comment = "ri xin" },
        },
        ["ri xing"] = {
            { text = "日行", comment = "ri xing" },
            { text = "日兴", comment = "ri xing" },
            { text = "日星", comment = "ri xing" },
        },
        ["ri xu"] = {
            { text = "日旭", comment = "ri xu" },
        },
        ["ri ya"] = {
            { text = "日亚", comment = "ri ya" },
        },
        ["ri yan"] = {
            { text = "日炎", comment = "ri yan" },
            { text = "日眼", comment = "ri yan" },
            { text = "日研", comment = "ri yan" },
        },
        ["ri yang"] = {
            { text = "日洋", comment = "ri yang" },
        },
        ["ri yao"] = {
            { text = "日曜", comment = "ri yao" },
            { text = "日耀", comment = "ri yao" },
        },
        ["ri ye"] = {
            { text = "日夜", comment = "ri ye" },
            { text = "日野", comment = "ri ye" },
            { text = "日业", comment = "ri ye" },
        },
        ["ri yi"] = {
            { text = "日益", comment = "ri yi" },
            { text = "日乙", comment = "ri yi" },
            { text = "日以", comment = "ri yi" },
        },
        ["ri ying"] = {
            { text = "日影", comment = "ri ying" },
            { text = "日盈", comment = "ri ying" },
        },
        ["ri yong"] = {
            { text = "日用", comment = "ri yong" },
        },
        ["ri you"] = {
            { text = "日游", comment = "ri you" },
            { text = "日邮", comment = "ri you" },
            { text = "日有", comment = "ri you" },
            { text = "日油", comment = "ri you" },
            { text = "日由", comment = "ri you" },
        },
        ["ri yu"] = {
            { text = "日语", comment = "ri yu" },
            { text = "日昱", comment = "ri yu" },
            { text = "日与", comment = "ri yu" },
            { text = "日于", comment = "ri yu" },
        },
        ["ri yuan"] = {
            { text = "日元", comment = "ri yuan" },
            { text = "日圆", comment = "ri yuan" },
            { text = "日源", comment = "ri yuan" },
        },
        ["ri yue"] = {
            { text = "日月", comment = "ri yue" },
        },
        ["ri yun"] = {
            { text = "日晕", comment = "ri yun" },
        },
        ["ri zai"] = {
            { text = "日在", comment = "ri zai" },
        },
        ["ri zhang"] = {
            { text = "日账", comment = "ri zhang" },
            { text = "日章", comment = "ri zhang" },
            { text = "日长", comment = "ri zhang" },
        },
        ["ri zhen"] = {
            { text = "日臻", comment = "ri zhen" },
        },
        ["ri zhi"] = {
            { text = "日志", comment = "ri zhi" },
            { text = "日至", comment = "ri zhi" },
            { text = "日制", comment = "ri zhi" },
            { text = "日职", comment = "ri zhi" },
            { text = "日止", comment = "ri zhi" },
            { text = "日置", comment = "ri zhi" },
            { text = "日支", comment = "ri zhi" },
        },
        ["ri zhong"] = {
            { text = "日中", comment = "ri zhong" },
            { text = "日终", comment = "ri zhong" },
        },
        ["ri zhou"] = {
            { text = "日周", comment = "ri zhou" },
        },
        ["ri zhu"] = {
            { text = "日主", comment = "ri zhu" },
            { text = "日柱", comment = "ri zhu" },
        },
        ["ri zhuang"] = {
            { text = "日妆", comment = "ri zhuang" },
            { text = "日庄", comment = "ri zhuang" },
        },
        ["rong ai"] = {
            { text = "绒癌", comment = "rong ai" },
        },
        ["rong an"] = {
            { text = "融安", comment = "rong an" },
            { text = "荣安", comment = "rong an" },
        },
        ["rong ao"] = {
            { text = "荣傲", comment = "rong ao" },
            { text = "荣奥", comment = "rong ao" },
        },
        ["rong bu"] = {
            { text = "绒布", comment = "rong bu" },
        },
        ["rong huai"] = {
            { text = "荣怀", comment = "rong huai" },
        },
        ["rong ou"] = {
            { text = "蓉欧", comment = "rong ou" },
        },
        ["rong ri"] = {
            { text = "容日", comment = "rong ri" },
        },
        ["rong wo"] = {
            { text = "容我", comment = "rong wo" },
            { text = "荣沃", comment = "rong wo" },
        },
        ["rong ye"] = {
            { text = "溶液", comment = "rong ye" },
            { text = "荣业", comment = "rong ye" },
        },
        ["rou"] = {
            { text = "肉", comment = "rou" },
            { text = "揉", comment = "rou" },
            { text = "柔", comment = "rou" },
            { text = "糅", comment = "rou" },
            { text = "蹂", comment = "rou" },
            { text = "鞣", comment = "rou" },
            { text = "月", comment = "rou" },
            { text = "𫐓", comment = "rou" },
        },
        ["rou a"] = {
            { text = "肉啊", comment = "rou a" },
        },
        ["rou cheng"] = {
            { text = "揉成", comment = "rou cheng" },
        },
        ["rou chu"] = {
            { text = "肉畜", comment = "rou chu" },
        },
        ["rou duo"] = {
            { text = "肉多", comment = "rou duo" },
        },
        ["rou hua"] = {
            { text = "柔滑", comment = "rou hua" },
            { text = "柔化", comment = "rou hua" },
            { text = "肉花", comment = "rou hua" },
        },
        ["rou hua suan"] = {
            { text = "鞣花酸", comment = "rou hua suan" },
        },
        ["rou le"] = {
            { text = "肉了", comment = "rou le" },
            { text = "揉了", comment = "rou le" },
        },
        ["rou liao"] = {
            { text = "鞣料", comment = "rou liao" },
        },
        ["rou qi"] = {
            { text = "肉鳍", comment = "rou qi" },
        },
        ["rou wan"] = {
            { text = "肉丸", comment = "rou wan" },
            { text = "柔婉", comment = "rou wan" },
        },
        ["rou yu"] = {
            { text = "柔宇", comment = "rou yu" },
            { text = "肉鱼", comment = "rou yu" },
            { text = "肉欲", comment = "rou yu" },
            { text = "柔宇", comment = "rou yu" },
            { text = "肉鱼", comment = "rou yu" },
            { text = "肉欲", comment = "rou yu" },
        },
        ["rou zhao"] = {
            { text = "肉爪", comment = "rou zhao" },
        },
        ["rou zhe"] = {
            { text = "揉着", comment = "rou zhe" },
        },
        ["rou zhen"] = {
            { text = "肉侦", comment = "rou zhen" },
        },
        ["ru ai"] = {
            { text = "乳癌", comment = "ru ai" },
        },
        ["ru ao"] = {
            { text = "儒岙", comment = "ru ao" },
        },
        ["ru ban"] = {
            { text = "入班", comment = "ru ban" },
        },
        ["ru bu"] = {
            { text = "如不", comment = "ru bu" },
            { text = "入不", comment = "ru bu" },
        },
        ["ru di"] = {
            { text = "入地", comment = "ru di" },
            { text = "入底", comment = "ru di" },
            { text = "如弟", comment = "ru di" },
        },
        ["ru fo"] = {
            { text = "如佛", comment = "ru fo" },
        },
        ["ru nan"] = {
            { text = "汝南", comment = "ru nan" },
        },
        ["ru nao"] = {
            { text = "入脑", comment = "ru nao" },
        },
        ["ru nei"] = {
            { text = "入内", comment = "ru nei" },
        },
        ["ru nie"] = {
            { text = "嚅嗫", comment = "ru nie" },
        },
        ["ru nin"] = {
            { text = "如您", comment = "ru nin" },
        },
        ["ru niu"] = {
            { text = "乳牛", comment = "ru niu" },
        },
        ["ru ou"] = {
            { text = "入欧", comment = "ru ou" },
        },
        ["ru yan"] = {
            { text = "如烟", comment = "ru yan" },
            { text = "入眼", comment = "ru yan" },
            { text = "入岩", comment = "ru yan" },
            { text = "如燕", comment = "ru yan" },
        },
        ["ru yao"] = {
            { text = "如要", comment = "ru yao" },
            { text = "入药", comment = "ru yao" },
            { text = "汝窑", comment = "ru yao" },
            { text = "乳摇", comment = "ru yao" },
            { text = "入窑", comment = "ru yao" },
        },
        ["ru yin"] = {
            { text = "如因", comment = "ru yin" },
            { text = "乳饮", comment = "ru yin" },
        },
        ["ru you"] = {
            { text = "如有", comment = "ru you" },
            { text = "乳油", comment = "ru you" },
        },
        ["ru yuan"] = {
            { text = "入院", comment = "ru yuan" },
            { text = "入园", comment = "ru yuan" },
            { text = "如愿", comment = "ru yuan" },
            { text = "乳源", comment = "ru yuan" },
            { text = "如园", comment = "ru yuan" },
            { text = "入院", comment = "ru yuan" },
            { text = "入园", comment = "ru yuan" },
            { text = "如愿", comment = "ru yuan" },
            { text = "乳源", comment = "ru yuan" },
            { text = "如园", comment = "ru yuan" },
        },
        ["ruan"] = {
            { text = "软", comment = "ruan" },
            { text = "阮", comment = "ruan" },
            { text = "朊", comment = "ruan" },
            { text = "堧", comment = "ruan" },
            { text = "瓀", comment = "ruan" },
            { text = "媆", comment = "ruan" },
        },
        ["ruan e"] = {
            { text = "软腭", comment = "ruan e" },
        },
        ["ruan tu"] = {
            { text = "软土", comment = "ruan tu" },
        },
        ["ruan yin"] = {
            { text = "软银", comment = "ruan yin" },
            { text = "软饮", comment = "ruan yin" },
        },
        ["ruan zhen"] = {
            { text = "软珍", comment = "ruan zhen" },
        },
        ["rui an"] = {
            { text = "瑞安", comment = "rui an" },
            { text = "锐安", comment = "rui an" },
            { text = "睿安", comment = "rui an" },
        },
        ["rui ao"] = {
            { text = "锐澳", comment = "rui ao" },
            { text = "瑞奥", comment = "rui ao" },
            { text = "瑞澳", comment = "rui ao" },
        },
        ["rui bu"] = {
            { text = "锐步", comment = "rui bu" },
        },
        ["rui ou"] = {
            { text = "锐欧", comment = "rui ou" },
            { text = "芮欧", comment = "rui ou" },
            { text = "瑞欧", comment = "rui ou" },
            { text = "锐欧", comment = "rui ou" },
            { text = "芮欧", comment = "rui ou" },
            { text = "瑞欧", comment = "rui ou" },
        },
        ["rui xu"] = {
            { text = "瑞旭", comment = "rui xu" },
        },
        ["rui yu"] = {
            { text = "瑞昱", comment = "rui yu" },
            { text = "瑞宇", comment = "rui yu" },
            { text = "瑞玉", comment = "rui yu" },
            { text = "瑞雨", comment = "rui yu" },
            { text = "睿宇", comment = "rui yu" },
            { text = "瑞誉", comment = "rui yu" },
            { text = "瑞瑜", comment = "rui yu" },
        },
        ["run an"] = {
            { text = "润安", comment = "run an" },
        },
        ["run ao"] = {
            { text = "润奥", comment = "run ao" },
        },
        ["run di"] = {
            { text = "润地", comment = "run di" },
            { text = "润迪", comment = "run di" },
        },
        ["run ye"] = {
            { text = "润叶", comment = "run ye" },
            { text = "润业", comment = "run ye" },
        },
        ["run yu"] = {
            { text = "润玉", comment = "run yu" },
            { text = "润宇", comment = "run yu" },
            { text = "润雨", comment = "run yu" },
            { text = "润玉", comment = "run yu" },
            { text = "润宇", comment = "run yu" },
            { text = "润雨", comment = "run yu" },
        },
        ["ruo"] = {
            { text = "若", comment = "ruo" },
            { text = "弱", comment = "ruo" },
            { text = "偌", comment = "ruo" },
            { text = "箬", comment = "ruo" },
            { text = "婼", comment = "ruo" },
            { text = "蒻", comment = "ruo" },
            { text = "爇", comment = "ruo" },
            { text = "鄀", comment = "ruo" },
        },
        ["ruo an"] = {
            { text = "若安", comment = "ruo an" },
        },
        ["ruo zhi"] = {
            { text = "弱智", comment = "ruo zhi" },
            { text = "若只", comment = "ruo zhi" },
        },
        ["sa a di"] = {
            { text = "萨阿迪", comment = "sa a di" },
        },
        ["sa ba"] = {
            { text = "萨巴", comment = "sa ba" },
        },
        ["sa fei"] = {
            { text = "萨菲", comment = "sa fei" },
        },
        ["sa nei"] = {
            { text = "萨内", comment = "sa nei" },
        },
        ["sa ni ang"] = {
            { text = "萨尼昂", comment = "sa ni ang" },
        },
        ["sa nuo"] = {
            { text = "萨诺", comment = "sa nuo" },
        },
        ["sa yan"] = {
            { text = "撒盐", comment = "sa yan" },
        },
        ["sa yao"] = {
            { text = "撒药", comment = "sa yao" },
        },
        ["sai an"] = {
            { text = "赛安", comment = "sai an" },
        },
        ["sai ao"] = {
            { text = "赛奥", comment = "sai ao" },
        },
        ["sai bu"] = {
            { text = "塞布", comment = "sai bu" },
        },
        ["sai ou"] = {
            { text = "赛欧", comment = "sai ou" },
        },
        ["san bu"] = {
            { text = "散步", comment = "san bu" },
            { text = "三部", comment = "san bu" },
            { text = "三步", comment = "san bu" },
            { text = "散布", comment = "san bu" },
            { text = "三不", comment = "san bu" },
            { text = "伞布", comment = "san bu" },
            { text = "三埠", comment = "san bu" },
        },
        ["san di"] = {
            { text = "三地", comment = "san di" },
            { text = "三弟", comment = "san di" },
            { text = "三迪", comment = "san di" },
            { text = "三蒂", comment = "san di" },
            { text = "三低", comment = "san di" },
        },
        ["san huai"] = {
            { text = "三槐", comment = "san huai" },
        },
        ["san ou"] = {
            { text = "三欧", comment = "san ou" },
        },
        ["san ri"] = {
            { text = "三日", comment = "san ri" },
        },
        ["san wo"] = {
            { text = "三沃", comment = "san wo" },
        },
        ["san yang"] = {
            { text = "三样", comment = "san yang" },
            { text = "散养", comment = "san yang" },
            { text = "三洋", comment = "san yang" },
            { text = "三阳", comment = "san yang" },
            { text = "三羊", comment = "san yang" },
            { text = "三养", comment = "san yang" },
            { text = "三杨", comment = "san yang" },
            { text = "三垟", comment = "san yang" },
            { text = "三扬", comment = "san yang" },
        },
        ["sang bu"] = {
            { text = "桑布", comment = "sang bu" },
        },
        ["sang ou"] = {
            { text = "丧偶", comment = "sang ou" },
        },
        ["sao a"] = {
            { text = "骚啊", comment = "sao a" },
        },
        ["se nie"] = {
            { text = "色孽", comment = "se nie" },
        },
        ["sen ye"] = {
            { text = "森业", comment = "sen ye" },
            { text = "森叶", comment = "sen ye" },
        },
        ["sha ba"] = {
            { text = "杀吧", comment = "sha ba" },
            { text = "沙坝", comment = "sha ba" },
            { text = "傻吧", comment = "sha ba" },
            { text = "沙巴", comment = "sha ba" },
            { text = "刹把", comment = "sha ba" },
            { text = "啥吧", comment = "sha ba" },
            { text = "沙扒", comment = "sha ba" },
        },
        ["sha bai"] = {
            { text = "傻白", comment = "sha bai" },
            { text = "煞白", comment = "sha bai" },
            { text = "沙白", comment = "sha bai" },
        },
        ["sha ban"] = {
            { text = "啥班", comment = "sha ban" },
            { text = "砂板", comment = "sha ban" },
            { text = "沙板", comment = "sha ban" },
        },
        ["sha bei"] = {
            { text = "傻呗", comment = "sha bei" },
            { text = "沙贝", comment = "sha bei" },
            { text = "沙北", comment = "sha bei" },
            { text = "沙陂", comment = "sha bei" },
        },
        ["sha ben"] = {
            { text = "啥本", comment = "sha ben" },
        },
        ["sha bo"] = {
            { text = "砂玻", comment = "sha bo" },
            { text = "沙伯", comment = "sha bo" },
            { text = "沙波", comment = "sha bo" },
        },
        ["sha bu"] = {
            { text = "纱布", comment = "sha bu" },
            { text = "砂布", comment = "sha bu" },
            { text = "杀不", comment = "sha bu" },
            { text = "沙埠", comment = "sha bu" },
            { text = "沙步", comment = "sha bu" },
        },
        ["sha ne"] = {
            { text = "啥呢", comment = "sha ne" },
        },
        ["sha nie"] = {
            { text = "砂镍", comment = "sha nie" },
        },
        ["sha niu"] = {
            { text = "傻妞", comment = "sha niu" },
            { text = "杀牛", comment = "sha niu" },
        },
        ["sha ou"] = {
            { text = "沙鸥", comment = "sha ou" },
        },
        ["sha ta"] = {
            { text = "杀他", comment = "sha ta" },
            { text = "杀塔", comment = "sha ta" },
        },
        ["sha tai"] = {
            { text = "沙太", comment = "sha tai" },
        },
        ["sha tan"] = {
            { text = "沙滩", comment = "sha tan" },
            { text = "沙坦", comment = "sha tan" },
        },
        ["sha tao"] = {
            { text = "沙涛", comment = "sha tao" },
        },
        ["sha te"] = {
            { text = "沙特", comment = "sha te" },
        },
        ["sha tie"] = {
            { text = "砂铁", comment = "sha tie" },
        },
        ["sha tou"] = {
            { text = "沙头", comment = "sha tou" },
            { text = "杀头", comment = "sha tou" },
        },
        ["sha tuo"] = {
            { text = "沙陀", comment = "sha tuo" },
        },
        ["sha yin"] = {
            { text = "砂银", comment = "sha yin" },
            { text = "沙银", comment = "sha yin" },
            { text = "沙音", comment = "sha yin" },
        },
        ["sha you"] = {
            { text = "沙优", comment = "sha you" },
        },
        ["sha yuan"] = {
            { text = "沙园", comment = "sha yuan" },
            { text = "沙源", comment = "sha yuan" },
        },
        ["shai bu"] = {
            { text = "晒布", comment = "shai bu" },
        },
        ["shai xu"] = {
            { text = "筛序", comment = "shai xu" },
        },
        ["shai yu"] = {
            { text = "筛余", comment = "shai yu" },
        },
        ["shan e"] = {
            { text = "善恶", comment = "shan e" },
            { text = "山阿", comment = "shan e" },
        },
        ["shan shan de"] = {
            { text = "闪闪的", comment = "shan shan de" },
        },
        ["shan shan e e"] = {
            { text = "善善恶恶", comment = "shan shan e e" },
        },
        ["shan ye"] = {
            { text = "山野", comment = "shan ye" },
            { text = "扇叶", comment = "shan ye" },
            { text = "善业", comment = "shan ye" },
            { text = "山叶", comment = "shan ye" },
            { text = "杉叶", comment = "shan ye" },
        },
        ["shan yu"] = {
            { text = "善于", comment = "shan yu" },
            { text = "山芋", comment = "shan yu" },
            { text = "鳝鱼", comment = "shan yu" },
            { text = "擅于", comment = "shan yu" },
            { text = "山语", comment = "shan yu" },
            { text = "山雨", comment = "shan yu" },
            { text = "善宇", comment = "shan yu" },
            { text = "善於", comment = "shan yu" },
        },
        ["shang a"] = {
            { text = "上啊", comment = "shang a" },
        },
        ["shang ai"] = {
            { text = "伤爱", comment = "shang ai" },
            { text = "尚爱", comment = "shang ai" },
        },
        ["shang an"] = {
            { text = "上岸", comment = "shang an" },
            { text = "上安", comment = "shang an" },
            { text = "尚安", comment = "shang an" },
            { text = "商安", comment = "shang an" },
            { text = "上案", comment = "shang an" },
        },
        ["shang ao"] = {
            { text = "上奥", comment = "shang ao" },
        },
        ["shang bu"] = {
            { text = "上不", comment = "shang bu" },
            { text = "上部", comment = "shang bu" },
            { text = "尚不", comment = "shang bu" },
            { text = "上步", comment = "shang bu" },
            { text = "商埠", comment = "shang bu" },
            { text = "商补", comment = "shang bu" },
            { text = "上埠", comment = "shang bu" },
        },
        ["shang e"] = {
            { text = "上颚", comment = "shang e" },
        },
        ["shang huai"] = {
            { text = "伤怀", comment = "shang huai" },
            { text = "上怀", comment = "shang huai" },
        },
        ["shang ri"] = {
            { text = "商日", comment = "shang ri" },
        },
        ["shang wo"] = {
            { text = "上我", comment = "shang wo" },
            { text = "伤我", comment = "shang wo" },
            { text = "赏我", comment = "shang wo" },
            { text = "上窝", comment = "shang wo" },
            { text = "尚沃", comment = "shang wo" },
        },
        ["shang ye"] = {
            { text = "商业", comment = "shang ye" },
            { text = "上野", comment = "shang ye" },
            { text = "上叶", comment = "shang ye" },
            { text = "上页", comment = "shang ye" },
            { text = "上也", comment = "shang ye" },
            { text = "上夜", comment = "shang ye" },
            { text = "上冶", comment = "shang ye" },
            { text = "尚业", comment = "shang ye" },
        },
        ["shao a"] = {
            { text = "少啊", comment = "shao a" },
        },
        ["shao ai"] = {
            { text = "少艾", comment = "shao ai" },
        },
        ["shao an"] = {
            { text = "稍安", comment = "shao an" },
            { text = "少安", comment = "shao an" },
            { text = "邵安", comment = "shao an" },
        },
        ["shao bu"] = {
            { text = "少补", comment = "shao bu" },
            { text = "少不", comment = "shao bu" },
            { text = "邵部", comment = "shao bu" },
        },
        ["shao di"] = {
            { text = "稍低", comment = "shao di" },
            { text = "邵迪", comment = "shao di" },
            { text = "少帝", comment = "shao di" },
            { text = "哨笛", comment = "shao di" },
        },
        ["shao en"] = {
            { text = "绍恩", comment = "shao en" },
        },
        ["shao o"] = {
            { text = "少哦", comment = "shao o" },
        },
        ["shao ou"] = {
            { text = "邵鸥", comment = "shao ou" },
        },
        ["she nei"] = {
            { text = "舍内", comment = "she nei" },
            { text = "社内", comment = "she nei" },
        },
        ["she niu"] = {
            { text = "麝牛", comment = "she niu" },
        },
        ["she nuan"] = {
            { text = "社暖", comment = "she nuan" },
        },
        ["she ta"] = {
            { text = "射他", comment = "she ta" },
        },
        ["she tai"] = {
            { text = "舌苔", comment = "she tai" },
        },
        ["she tan"] = {
            { text = "设摊", comment = "she tan" },
            { text = "社坛", comment = "she tan" },
            { text = "奢谈", comment = "she tan" },
        },
        ["she tie"] = {
            { text = "涉铁", comment = "she tie" },
        },
        ["she tou"] = {
            { text = "舌头", comment = "she tou" },
            { text = "蛇头", comment = "she tou" },
            { text = "社头", comment = "she tou" },
        },
        ["she tuan"] = {
            { text = "社团", comment = "she tuan" },
        },
        ["she you"] = {
            { text = "舍友", comment = "she you" },
            { text = "设有", comment = "she you" },
            { text = "蛇油", comment = "she you" },
            { text = "摄友", comment = "she you" },
            { text = "社友", comment = "she you" },
        },
        ["she yue"] = {
            { text = "蛇岳", comment = "she yue" },
            { text = "奢悦", comment = "she yue" },
            { text = "射月", comment = "she yue" },
            { text = "折跃", comment = "she yue" },
        },
        ["shei bu"] = {
            { text = "谁不", comment = "shei bu" },
        },
        ["shei ne"] = {
            { text = "谁呢", comment = "shei ne" },
        },
        ["shen ao"] = {
            { text = "深奥", comment = "shen ao" },
            { text = "申奥", comment = "shen ao" },
            { text = "神奥", comment = "shen ao" },
            { text = "深澳", comment = "shen ao" },
        },
        ["shen bu"] = {
            { text = "深部", comment = "shen bu" },
            { text = "神捕", comment = "shen bu" },
            { text = "肾部", comment = "shen bu" },
            { text = "沈部", comment = "shen bu" },
        },
        ["shen di"] = {
            { text = "神帝", comment = "shen di" },
            { text = "沈迪", comment = "shen di" },
            { text = "申迪", comment = "shen di" },
            { text = "神邸", comment = "shen di" },
            { text = "深地", comment = "shen di" },
        },
        ["shen fo"] = {
            { text = "神佛", comment = "shen fo" },
        },
        ["shen ou"] = {
            { text = "申瓯", comment = "shen ou" },
        },
        ["shen xu"] = {
            { text = "肾虚", comment = "shen xu" },
            { text = "沈旭", comment = "shen xu" },
            { text = "神婿", comment = "shen xu" },
            { text = "参须", comment = "shen xu" },
            { text = "申旭", comment = "shen xu" },
        },
        ["shen yu"] = {
            { text = "神域", comment = "shen yu" },
            { text = "神谕", comment = "shen yu" },
            { text = "肾盂", comment = "shen yu" },
            { text = "神宇", comment = "shen yu" },
            { text = "甚于", comment = "shen yu" },
            { text = "沈玉", comment = "shen yu" },
            { text = "沈宇", comment = "shen yu" },
            { text = "神羽", comment = "shen yu" },
            { text = "沈瑜", comment = "shen yu" },
            { text = "申宇", comment = "shen yu" },
            { text = "神玉", comment = "shen yu" },
            { text = "神鱼", comment = "shen yu" },
            { text = "沈雨", comment = "shen yu" },
            { text = "沈钰", comment = "shen yu" },
            { text = "沈煜", comment = "shen yu" },
            { text = "神语", comment = "shen yu" },
            { text = "神御", comment = "shen yu" },
            { text = "申雨", comment = "shen yu" },
            { text = "沈遇", comment = "shen yu" },
        },
        ["sheng a"] = {
            { text = "生啊", comment = "sheng a" },
        },
        ["sheng ai"] = {
            { text = "圣爱", comment = "sheng ai" },
        },
        ["sheng an"] = {
            { text = "圣安", comment = "sheng an" },
            { text = "盛安", comment = "sheng an" },
            { text = "省安", comment = "sheng an" },
            { text = "胜安", comment = "sheng an" },
            { text = "盛岸", comment = "sheng an" },
            { text = "晟安", comment = "sheng an" },
        },
        ["sheng ao"] = {
            { text = "圣奥", comment = "sheng ao" },
            { text = "盛奥", comment = "sheng ao" },
        },
        ["sheng bu"] = {
            { text = "声部", comment = "sheng bu" },
            { text = "省部", comment = "sheng bu" },
            { text = "省补", comment = "sheng bu" },
        },
        ["sheng fo"] = {
            { text = "圣佛", comment = "sheng fo" },
        },
        ["sheng ou"] = {
            { text = "生藕", comment = "sheng ou" },
        },
        ["sheng xu"] = {
            { text = "升序", comment = "sheng xu" },
            { text = "圣墟", comment = "sheng xu" },
            { text = "盛旭", comment = "sheng xu" },
            { text = "牲畜", comment = "sheng xu" },
        },
        ["sheng ye"] = {
            { text = "盛业", comment = "sheng ye" },
            { text = "生椰", comment = "sheng ye" },
            { text = "胜业", comment = "sheng ye" },
            { text = "生业", comment = "sheng ye" },
            { text = "圣夜", comment = "sheng ye" },
            { text = "晟业", comment = "sheng ye" },
            { text = "盛烨", comment = "sheng ye" },
        },
        ["shi ao"] = {
            { text = "石澳", comment = "shi ao" },
            { text = "世奥", comment = "shi ao" },
            { text = "石坳", comment = "shi ao" },
        },
        ["shi bu"] = {
            { text = "是不", comment = "shi bu" },
            { text = "食补", comment = "shi bu" },
            { text = "十步", comment = "shi bu" },
            { text = "湿布", comment = "shi bu" },
            { text = "十部", comment = "shi bu" },
            { text = "石埠", comment = "shi bu" },
            { text = "实部", comment = "shi bu" },
            { text = "时不", comment = "shi bu" },
            { text = "师部", comment = "shi bu" },
            { text = "失步", comment = "shi bu" },
            { text = "史部", comment = "shi bu" },
            { text = "石步", comment = "shi bu" },
            { text = "市布", comment = "shi bu" },
        },
        ["shi die"] = {
            { text = "师爹", comment = "shi die" },
        },
        ["shi e ye"] = {
            { text = "十恶业", comment = "shi e ye" },
        },
        ["shi fo"] = {
            { text = "是佛", comment = "shi fo" },
            { text = "石佛", comment = "shi fo" },
        },
        ["shi huai"] = {
            { text = "释怀", comment = "shi huai" },
            { text = "使坏", comment = "shi huai" },
            { text = "是坏", comment = "shi huai" },
        },
        ["shi ou"] = {
            { text = "是偶", comment = "shi ou" },
            { text = "世欧", comment = "shi ou" },
        },
        ["shi qi ta"] = {
            { text = "是其他", comment = "shi qi ta" },
        },
        ["shi qing a"] = {
            { text = "事情啊", comment = "shi qing a" },
        },
        ["shi ri"] = {
            { text = "十日", comment = "shi ri" },
            { text = "时日", comment = "shi ri" },
            { text = "是日", comment = "shi ri" },
        },
        ["shou ao"] = {
            { text = "手坳", comment = "shou ao" },
        },
        ["shou bu"] = {
            { text = "收不", comment = "shou bu" },
            { text = "手部", comment = "shou bu" },
            { text = "受不", comment = "shou bu" },
            { text = "首部", comment = "shou bu" },
            { text = "熟不", comment = "shou bu" },
            { text = "手簿", comment = "shou bu" },
            { text = "艏部", comment = "shou bu" },
            { text = "受醭", comment = "shou bu" },
        },
        ["shou fo"] = {
            { text = "寿佛", comment = "shou fo" },
        },
        ["shou ou"] = {
            { text = "手偶", comment = "shou ou" },
        },
        ["shu ba"] = {
            { text = "书吧", comment = "shu ba" },
        },
        ["shu bai"] = {
            { text = "数百", comment = "shu bai" },
            { text = "叔伯", comment = "shu bai" },
            { text = "属白", comment = "shu bai" },
        },
        ["shu ban"] = {
            { text = "竖版", comment = "shu ban" },
            { text = "竖板", comment = "shu ban" },
            { text = "输半", comment = "shu ban" },
        },
        ["shu bei"] = {
            { text = "数倍", comment = "shu bei" },
            { text = "鼠辈", comment = "shu bei" },
            { text = "书背", comment = "shu bei" },
            { text = "数北", comment = "shu bei" },
        },
        ["shu bin"] = {
            { text = "舒斌", comment = "shu bin" },
            { text = "树斌", comment = "shu bin" },
            { text = "树彬", comment = "shu bin" },
            { text = "书彬", comment = "shu bin" },
        },
        ["shu bo"] = {
            { text = "数博", comment = "shu bo" },
            { text = "舒波", comment = "shu bo" },
            { text = "树波", comment = "shu bo" },
            { text = "蜀玻", comment = "shu bo" },
            { text = "书博", comment = "shu bo" },
        },
        ["shu huai"] = {
            { text = "抒怀", comment = "shu huai" },
            { text = "述怀", comment = "shu huai" },
        },
        ["shu nan"] = {
            { text = "蜀南", comment = "shu nan" },
            { text = "熟男", comment = "shu nan" },
            { text = "舒楠", comment = "shu nan" },
        },
        ["shu niu"] = {
            { text = "枢纽", comment = "shu niu" },
            { text = "属牛", comment = "shu niu" },
            { text = "蜀牛", comment = "shu niu" },
            { text = "鼠牛", comment = "shu niu" },
        },
        ["shu ri"] = {
            { text = "数日", comment = "shu ri" },
            { text = "舒日", comment = "shu ri" },
        },
        ["shu ya"] = {
            { text = "舒雅", comment = "shu ya" },
            { text = "淑雅", comment = "shu ya" },
            { text = "舒压", comment = "shu ya" },
            { text = "书雅", comment = "shu ya" },
            { text = "姝雅", comment = "shu ya" },
            { text = "舒亚", comment = "shu ya" },
            { text = "树桠", comment = "shu ya" },
        },
        ["shu yan"] = {
            { text = "舒颜", comment = "shu yan" },
            { text = "淑艳", comment = "shu yan" },
            { text = "淑燕", comment = "shu yan" },
            { text = "舒燕", comment = "shu yan" },
            { text = "舒妍", comment = "shu yan" },
            { text = "书言", comment = "shu yan" },
            { text = "舒艳", comment = "shu yan" },
            { text = "淑妍", comment = "shu yan" },
            { text = "姝妍", comment = "shu yan" },
            { text = "书妍", comment = "shu yan" },
        },
        ["shu yang"] = {
            { text = "沭阳", comment = "shu yang" },
            { text = "属羊", comment = "shu yang" },
            { text = "数羊", comment = "shu yang" },
            { text = "输氧", comment = "shu yang" },
            { text = "舒扬", comment = "shu yang" },
            { text = "舒阳", comment = "shu yang" },
            { text = "蜀阳", comment = "shu yang" },
            { text = "舒杨", comment = "shu yang" },
            { text = "蜀羊", comment = "shu yang" },
            { text = "舒洋", comment = "shu yang" },
            { text = "书洋", comment = "shu yang" },
            { text = "舒痒", comment = "shu yang" },
        },
        ["shu yao"] = {
            { text = "树妖", comment = "shu yao" },
            { text = "束腰", comment = "shu yao" },
            { text = "鼠药", comment = "shu yao" },
            { text = "书瑶", comment = "shu yao" },
            { text = "舒瑶", comment = "shu yao" },
            { text = "书腰", comment = "shu yao" },
            { text = "舒窈", comment = "shu yao" },
            { text = "枢要", comment = "shu yao" },
        },
        ["shu ye"] = {
            { text = "输液", comment = "shu ye" },
            { text = "树叶", comment = "shu ye" },
            { text = "书页", comment = "shu ye" },
            { text = "术业", comment = "shu ye" },
            { text = "术爷", comment = "shu ye" },
            { text = "书业", comment = "shu ye" },
            { text = "术野", comment = "shu ye" },
            { text = "鼠爷", comment = "shu ye" },
            { text = "树业", comment = "shu ye" },
            { text = "树液", comment = "shu ye" },
        },
        ["shu yin"] = {
            { text = "树荫", comment = "shu yin" },
            { text = "舒音", comment = "shu yin" },
            { text = "术印", comment = "shu yin" },
            { text = "树阴", comment = "shu yin" },
            { text = "数印", comment = "shu yin" },
        },
        ["shu you"] = {
            { text = "书友", comment = "shu you" },
            { text = "输油", comment = "shu you" },
            { text = "舒友", comment = "shu you" },
            { text = "癙忧", comment = "shu you" },
        },
        ["shu you hui"] = {
            { text = "书友会", comment = "shu you hui" },
        },
        ["shu yue"] = {
            { text = "数月", comment = "shu yue" },
            { text = "舒悦", comment = "shu yue" },
            { text = "舒月", comment = "shu yue" },
            { text = "淑月", comment = "shu yue" },
            { text = "书悦", comment = "shu yue" },
        },
        ["shu yun"] = {
            { text = "输运", comment = "shu yun" },
            { text = "淑云", comment = "shu yun" },
            { text = "暑运", comment = "shu yun" },
            { text = "数云", comment = "shu yun" },
            { text = "舒云", comment = "shu yun" },
            { text = "书云", comment = "shu yun" },
            { text = "疏运", comment = "shu yun" },
            { text = "书韵", comment = "shu yun" },
            { text = "蜀韵", comment = "shu yun" },
        },
        ["shua ta"] = {
            { text = "刷塔", comment = "shua ta" },
        },
        ["shua tao"] = {
            { text = "刷套", comment = "shua tao" },
        },
        ["shua tie"] = {
            { text = "刷帖", comment = "shua tie" },
            { text = "刷贴", comment = "shua tie" },
        },
        ["shua tou"] = {
            { text = "刷头", comment = "shua tou" },
            { text = "耍头", comment = "shua tou" },
        },
        ["shua ya"] = {
            { text = "刷牙", comment = "shua ya" },
            { text = "耍呀", comment = "shua ya" },
        },
        ["shua ye"] = {
            { text = "刷野", comment = "shua ye" },
            { text = "刷夜", comment = "shua ye" },
        },
        ["shua you"] = {
            { text = "刷油", comment = "shua you" },
        },
        ["shuai a"] = {
            { text = "帅啊", comment = "shuai a" },
        },
        ["shuai bu"] = {
            { text = "帅不", comment = "shuai bu" },
            { text = "率部", comment = "shuai bu" },
        },
        ["shuai e"] = {
            { text = "帅哦", comment = "shuai e" },
        },
        ["shuang a"] = {
            { text = "爽啊", comment = "shuang a" },
        },
        ["shuang ao"] = {
            { text = "双凹", comment = "shuang ao" },
            { text = "双奥", comment = "shuang ao" },
        },
        ["shuang bu"] = {
            { text = "爽不", comment = "shuang bu" },
            { text = "双埠", comment = "shuang bu" },
        },
        ["shuang huai"] = {
            { text = "双槐", comment = "shuang huai" },
        },
        ["shuang ou"] = {
            { text = "双欧", comment = "shuang ou" },
        },
        ["shuang ri"] = {
            { text = "双日", comment = "shuang ri" },
        },
        ["shuang ye"] = {
            { text = "双野", comment = "shuang ye" },
            { text = "双叶", comment = "shuang ye" },
            { text = "霜叶", comment = "shuang ye" },
            { text = "双业", comment = "shuang ye" },
            { text = "爽爷", comment = "shuang ye" },
        },
        ["shui a"] = {
            { text = "谁啊", comment = "shui a" },
            { text = "睡啊", comment = "shui a" },
            { text = "水啊", comment = "shui a" },
        },
        ["shui an"] = {
            { text = "水岸", comment = "shui an" },
            { text = "水安", comment = "shui an" },
        },
        ["shui ang"] = {
            { text = "水昂", comment = "shui ang" },
        },
        ["shui bu"] = {
            { text = "睡不", comment = "shui bu" },
            { text = "谁不", comment = "shui bu" },
            { text = "水部", comment = "shui bu" },
            { text = "水步", comment = "shui bu" },
        },
        ["shui bu hui"] = {
            { text = "谁不会", comment = "shui bu hui" },
        },
        ["shui e"] = {
            { text = "税额", comment = "shui e" },
            { text = "谁哦", comment = "shui e" },
        },
        ["shui fo"] = {
            { text = "睡佛", comment = "shui fo" },
        },
        ["shui ne"] = {
            { text = "睡呢", comment = "shui ne" },
        },
        ["shui nv"] = {
            { text = "水女", comment = "shui nv" },
        },
        ["shui yu"] = {
            { text = "水域", comment = "shui yu" },
            { text = "水浴", comment = "shui yu" },
            { text = "水鱼", comment = "shui yu" },
            { text = "水玉", comment = "shui yu" },
            { text = "水育", comment = "shui yu" },
            { text = "水峪", comment = "shui yu" },
            { text = "水语", comment = "shui yu" },
            { text = "水盂", comment = "shui yu" },
            { text = "税込", comment = "shui yu" },
        },
        ["shun an"] = {
            { text = "顺安", comment = "shun an" },
        },
        ["shun yu"] = {
            { text = "舜玉", comment = "shun yu" },
            { text = "舜宇", comment = "shun yu" },
            { text = "顺宇", comment = "shun yu" },
            { text = "顺裕", comment = "shun yu" },
            { text = "顺玉", comment = "shun yu" },
        },
        ["shuo a"] = {
            { text = "说啊", comment = "shuo a" },
        },
        ["shuo ai"] = {
            { text = "说爱", comment = "shuo ai" },
        },
        ["shuo an"] = {
            { text = "说案", comment = "shuo an" },
        },
        ["shuo di"] = {
            { text = "说滴", comment = "shuo di" },
            { text = "说地", comment = "shuo di" },
        },
        ["shuo huai"] = {
            { text = "说坏", comment = "shuo huai" },
        },
        ["shuo o"] = {
            { text = "说哦", comment = "shuo o" },
        },
        ["shuo ri"] = {
            { text = "朔日", comment = "shuo ri" },
            { text = "硕日", comment = "shuo ri" },
        },
        ["shuo yu"] = {
            { text = "朔玉", comment = "shuo yu" },
            { text = "硕宇", comment = "shuo yu" },
            { text = "硕预", comment = "shuo yu" },
            { text = "烁宇", comment = "shuo yu" },
        },
        ["si huai"] = {
            { text = "撕坏", comment = "si huai" },
        },
        ["si ri"] = {
            { text = "四日", comment = "si ri" },
        },
        ["si ya tou"] = {
            { text = "死丫头", comment = "si ya tou" },
        },
        ["si yang bu"] = {
            { text = "饲养部", comment = "si yang bu" },
        },
        ["song ao"] = {
            { text = "宋傲", comment = "song ao" },
            { text = "松岙", comment = "song ao" },
        },
        ["song fo"] = {
            { text = "送佛", comment = "song fo" },
        },
        ["su bai"] = {
            { text = "素白", comment = "su bai" },
            { text = "苏白", comment = "su bai" },
        },
        ["su bei"] = {
            { text = "苏北", comment = "su bei" },
            { text = "肃北", comment = "su bei" },
            { text = "塑杯", comment = "su bei" },
            { text = "苏杯", comment = "su bei" },
        },
        ["su ben"] = {
            { text = "速本", comment = "su ben" },
            { text = "宿本", comment = "su ben" },
        },
        ["su bie"] = {
            { text = "苏别", comment = "su bie" },
        },
        ["su bin"] = {
            { text = "苏斌", comment = "su bin" },
            { text = "苏彬", comment = "su bin" },
        },
        ["su huai"] = {
            { text = "苏怀", comment = "su huai" },
        },
        ["su nan"] = {
            { text = "苏南", comment = "su nan" },
            { text = "苏楠", comment = "su nan" },
            { text = "肃南", comment = "su nan" },
        },
        ["su nuan"] = {
            { text = "苏暖", comment = "su nuan" },
        },
        ["su nuo"] = {
            { text = "速诺", comment = "su nuo" },
            { text = "宿傩", comment = "su nuo" },
            { text = "苏诺", comment = "su nuo" },
            { text = "宿诺", comment = "su nuo" },
            { text = "夙诺", comment = "su nuo" },
        },
        ["su ri"] = {
            { text = "素日", comment = "su ri" },
            { text = "苏日", comment = "su ri" },
        },
        ["su ya"] = {
            { text = "素雅", comment = "su ya" },
            { text = "苏亚", comment = "su ya" },
            { text = "苏雅", comment = "su ya" },
            { text = "苏牙", comment = "su ya" },
            { text = "苏娅", comment = "su ya" },
        },
        ["su yan"] = {
            { text = "素颜", comment = "su yan" },
            { text = "苏烟", comment = "su yan" },
            { text = "塑颜", comment = "su yan" },
            { text = "苏艳", comment = "su yan" },
            { text = "苏燕", comment = "su yan" },
            { text = "苏研", comment = "su yan" },
            { text = "苏岩", comment = "su yan" },
            { text = "苏妍", comment = "su yan" },
            { text = "苏盐", comment = "su yan" },
            { text = "苏言", comment = "su yan" },
            { text = "素妍", comment = "su yan" },
            { text = "苏颜", comment = "su yan" },
            { text = "素言", comment = "su yan" },
            { text = "苏焱", comment = "su yan" },
            { text = "素艳", comment = "su yan" },
        },
        ["su yin"] = {
            { text = "素银", comment = "su yin" },
            { text = "速印", comment = "su yin" },
            { text = "苏银", comment = "su yin" },
            { text = "苏音", comment = "su yin" },
        },
        ["su you"] = {
            { text = "素有", comment = "su you" },
            { text = "宿友", comment = "su you" },
            { text = "酥油", comment = "su you" },
            { text = "苏友", comment = "su you" },
            { text = "素油", comment = "su you" },
            { text = "速优", comment = "su you" },
        },
        ["su yuan"] = {
            { text = "溯源", comment = "su yuan" },
            { text = "素媛", comment = "su yuan" },
            { text = "夙愿", comment = "su yuan" },
            { text = "苏源", comment = "su yuan" },
            { text = "苏园", comment = "su yuan" },
            { text = "苏元", comment = "su yuan" },
            { text = "苏苑", comment = "su yuan" },
            { text = "苏媛", comment = "su yuan" },
            { text = "宿怨", comment = "su yuan" },
            { text = "宿愿", comment = "su yuan" },
            { text = "诉愿", comment = "su yuan" },
            { text = "诉冤", comment = "su yuan" },
            { text = "夙怨", comment = "su yuan" },
            { text = "素愿", comment = "su yuan" },
        },
        ["sui a"] = {
            { text = "岁啊", comment = "sui a" },
        },
        ["sui an"] = {
            { text = "绥安", comment = "sui an" },
            { text = "穗安", comment = "sui an" },
        },
        ["sui bu"] = {
            { text = "碎步", comment = "sui bu" },
            { text = "碎布", comment = "sui bu" },
            { text = "虽不", comment = "sui bu" },
        },
        ["sui xu"] = {
            { text = "岁序", comment = "sui xu" },
        },
        ["sui yu"] = {
            { text = "碎玉", comment = "sui yu" },
            { text = "随遇", comment = "sui yu" },
            { text = "碎语", comment = "sui yu" },
            { text = "隋玉", comment = "sui yu" },
            { text = "随寓", comment = "sui yu" },
        },
        ["sun an"] = {
            { text = "孙安", comment = "sun an" },
        },
        ["sun wo"] = {
            { text = "损我", comment = "sun wo" },
        },
        ["sun xu"] = {
            { text = "孙旭", comment = "sun xu" },
        },
        ["suo ai"] = {
            { text = "所爱", comment = "suo ai" },
            { text = "索爱", comment = "suo ai" },
            { text = "锁爱", comment = "suo ai" },
        },
        ["suo di"] = {
            { text = "索敌", comment = "suo di" },
            { text = "缩地", comment = "suo di" },
            { text = "索迪", comment = "suo di" },
        },
        ["suo en"] = {
            { text = "索恩", comment = "suo en" },
        },
        ["suo ye"] = {
            { text = "索爷", comment = "suo ye" },
            { text = "锁业", comment = "suo ye" },
        },
        ["suo yu"] = {
            { text = "所欲", comment = "suo yu" },
            { text = "所遇", comment = "suo yu" },
            { text = "梭鱼", comment = "suo yu" },
        },
        ["ta ban"] = {
            { text = "踏板", comment = "ta ban" },
            { text = "她班", comment = "ta ban" },
            { text = "塔板", comment = "ta ban" },
        },
        ["ta bei"] = {
            { text = "他被", comment = "ta bei" },
            { text = "她被", comment = "ta bei" },
            { text = "它被", comment = "ta bei" },
            { text = "塔北", comment = "ta bei" },
            { text = "拓碑", comment = "ta bei" },
        },
        ["ta bie"] = {
            { text = "他别", comment = "ta bie" },
        },
        ["ta nai"] = {
            { text = "他奶", comment = "ta nai" },
        },
        ["ta nan"] = {
            { text = "塔南", comment = "ta nan" },
        },
        ["ta nei"] = {
            { text = "塔内", comment = "ta nei" },
        },
        ["ta nuo"] = {
            { text = "阘懦", comment = "ta nuo" },
        },
        ["ta ta"] = {
            { text = "塔塔", comment = "ta ta" },
            { text = "他他", comment = "ta ta" },
            { text = "踏踏", comment = "ta ta" },
            { text = "她他", comment = "ta ta" },
            { text = "塌塌", comment = "ta ta" },
            { text = "他她", comment = "ta ta" },
            { text = "她她", comment = "ta ta" },
            { text = "闼闼", comment = "ta ta" },
        },
        ["ta tai"] = {
            { text = "他太", comment = "ta tai" },
            { text = "塔台", comment = "ta tai" },
            { text = "塌台", comment = "ta tai" },
        },
        ["ta tan"] = {
            { text = "塔谈", comment = "ta tan" },
            { text = "塔坛", comment = "ta tan" },
        },
        ["ta tou"] = {
            { text = "塔头", comment = "ta tou" },
        },
        ["ta tuan"] = {
            { text = "拓团", comment = "ta tuan" },
        },
        ["ta tuo"] = {
            { text = "塔坨", comment = "ta tuo" },
        },
        ["ta ya"] = {
            { text = "他呀", comment = "ta ya" },
        },
        ["ta yan"] = {
            { text = "踏炎", comment = "ta yan" },
        },
        ["ta yang"] = {
            { text = "塌秧", comment = "ta yang" },
            { text = "塔洋", comment = "ta yang" },
            { text = "拓样", comment = "ta yang" },
        },
        ["ta yao"] = {
            { text = "他要", comment = "ta yao" },
            { text = "她要", comment = "ta yao" },
            { text = "它要", comment = "ta yao" },
            { text = "塌腰", comment = "ta yao" },
        },
        ["ta ye"] = {
            { text = "他也", comment = "ta ye" },
            { text = "她也", comment = "ta ye" },
            { text = "它也", comment = "ta ye" },
            { text = "他爷", comment = "ta ye" },
        },
        ["ta yin"] = {
            { text = "拓印", comment = "ta yin" },
            { text = "他因", comment = "ta yin" },
            { text = "他引", comment = "ta yin" },
        },
        ["ta you"] = {
            { text = "他有", comment = "ta you" },
            { text = "他又", comment = "ta you" },
            { text = "她有", comment = "ta you" },
            { text = "她又", comment = "ta you" },
            { text = "它有", comment = "ta you" },
            { text = "它又", comment = "ta you" },
            { text = "它由", comment = "ta you" },
        },
        ["ta yuan"] = {
            { text = "塔院", comment = "ta yuan" },
            { text = "塔园", comment = "ta yuan" },
            { text = "塔院", comment = "ta yuan" },
            { text = "塔园", comment = "ta yuan" },
        },
        ["tai a"] = {
            { text = "太阿", comment = "tai a" },
            { text = "泰阿", comment = "tai a" },
        },
        ["tai an"] = {
            { text = "泰安", comment = "tai an" },
            { text = "太暗", comment = "tai an" },
            { text = "台安", comment = "tai an" },
            { text = "太安", comment = "tai an" },
        },
        ["tai ang"] = {
            { text = "泰昂", comment = "tai ang" },
        },
        ["tai ao"] = {
            { text = "太傲", comment = "tai ao" },
            { text = "太奥", comment = "tai ao" },
        },
        ["tai bu"] = {
            { text = "太不", comment = "tai bu" },
            { text = "台布", comment = "tai bu" },
            { text = "太补", comment = "tai bu" },
            { text = "台步", comment = "tai bu" },
        },
        ["tai e"] = {
            { text = "太阿", comment = "tai e" },
            { text = "太饿", comment = "tai e" },
            { text = "泰阿", comment = "tai e" },
        },
        ["tai huai"] = {
            { text = "太坏", comment = "tai huai" },
        },
        ["tai ou"] = {
            { text = "太欧", comment = "tai ou" },
            { text = "太欧", comment = "tai ou" },
        },
        ["tai ri"] = {
            { text = "泰日", comment = "tai ri" },
            { text = "台日", comment = "tai ri" },
        },
        ["tai xu"] = {
            { text = "太虚", comment = "tai xu" },
            { text = "泰旭", comment = "tai xu" },
        },
        ["tai yu"] = {
            { text = "泰语", comment = "tai yu" },
            { text = "泰宇", comment = "tai yu" },
            { text = "台语", comment = "tai yu" },
            { text = "太宇", comment = "tai yu" },
            { text = "泰裕", comment = "tai yu" },
            { text = "泰禹", comment = "tai yu" },
            { text = "鲐鱼", comment = "tai yu" },
        },
        ["tan ai"] = {
            { text = "谈爱", comment = "tan ai" },
        },
        ["tan an"] = {
            { text = "探案", comment = "tan an" },
            { text = "碳铵", comment = "tan an" },
        },
        ["tan di"] = {
            { text = "探底", comment = "tan di" },
            { text = "滩地", comment = "tan di" },
            { text = "探地", comment = "tan di" },
        },
        ["tan wo"] = {
            { text = "弹我", comment = "tan wo" },
        },
        ["tang a"] = {
            { text = "糖啊", comment = "tang a" },
        },
        ["tang ai"] = {
            { text = "汤爱", comment = "tang ai" },
        },
        ["tang an"] = {
            { text = "唐安", comment = "tang an" },
            { text = "塘岸", comment = "tang an" },
        },
        ["tang bu"] = {
            { text = "唐部", comment = "tang bu" },
            { text = "塘步", comment = "tang bu" },
        },
        ["tang ou"] = {
            { text = "糖藕", comment = "tang ou" },
        },
        ["tang wo"] = {
            { text = "躺我", comment = "tang wo" },
        },
        ["tang xu"] = {
            { text = "唐旭", comment = "tang xu" },
            { text = "汤旭", comment = "tang xu" },
        },
        ["tao an"] = {
            { text = "陶安", comment = "tao an" },
        },
        ["tao di"] = {
            { text = "陶笛", comment = "tao di" },
            { text = "涛弟", comment = "tao di" },
            { text = "掏底", comment = "tao di" },
        },
        ["tao hua an"] = {
            { text = "桃花庵", comment = "tao hua an" },
        },
        ["tao ran"] = {
            { text = "陶然", comment = "tao ran" },
            { text = "陶冉", comment = "tao ran" },
        },
        ["tao ye"] = {
            { text = "陶冶", comment = "tao ye" },
            { text = "桃叶", comment = "tao ye" },
            { text = "涛爷", comment = "tao ye" },
            { text = "逃夜", comment = "tao ye" },
        },
        ["te tai"] = {
            { text = "特太", comment = "te tai" },
        },
        ["te tao"] = {
            { text = "特陶", comment = "te tao" },
        },
        ["te tie"] = {
            { text = "特贴", comment = "te tie" },
        },
        ["teng ai"] = {
            { text = "疼爱", comment = "teng ai" },
        },
        ["teng ao"] = {
            { text = "腾鳌", comment = "teng ao" },
        },
        ["teng ye"] = {
            { text = "藤野", comment = "teng ye" },
            { text = "腾业", comment = "teng ye" },
        },
        ["ti bu"] = {
            { text = "替补", comment = "ti bu" },
            { text = "梯步", comment = "ti bu" },
            { text = "提布", comment = "ti bu" },
            { text = "体部", comment = "ti bu" },
            { text = "屉布", comment = "ti bu" },
        },
        ["ti da"] = {
            { text = "踢打", comment = "ti da" },
            { text = "剔打", comment = "ti da" },
            { text = "体大", comment = "ti da" },
        },
        ["ti dan"] = {
            { text = "提单", comment = "ti dan" },
            { text = "题单", comment = "ti dan" },
            { text = "踢单", comment = "ti dan" },
        },
        ["ti dao"] = {
            { text = "提到", comment = "ti dao" },
            { text = "踢到", comment = "ti dao" },
            { text = "提刀", comment = "ti dao" },
            { text = "剃刀", comment = "ti dao" },
            { text = "梯道", comment = "ti dao" },
            { text = "薙刀", comment = "ti dao" },
        },
        ["ti dou"] = {
            { text = "提都", comment = "ti dou" },
        },
        ["ti duo"] = {
            { text = "提多", comment = "ti duo" },
        },
        ["ti e"] = {
            { text = "提额", comment = "ti e" },
        },
        ["ti ou"] = {
            { text = "缇欧", comment = "ti ou" },
            { text = "提偶", comment = "ti ou" },
        },
        ["ti ta"] = {
            { text = "替他", comment = "ti ta" },
            { text = "替她", comment = "ti ta" },
            { text = "踢他", comment = "ti ta" },
            { text = "提他", comment = "ti ta" },
            { text = "踢踏", comment = "ti ta" },
        },
        ["ti tai"] = {
            { text = "体态", comment = "ti tai" },
            { text = "梯台", comment = "ti tai" },
        },
        ["ti tao"] = {
            { text = "踢桃", comment = "ti tao" },
        },
        ["ti te"] = {
            { text = "体特", comment = "ti te" },
        },
        ["ti tie"] = {
            { text = "体贴", comment = "ti tie" },
            { text = "蹄铁", comment = "ti tie" },
        },
        ["ti tou"] = {
            { text = "剃头", comment = "ti tou" },
            { text = "题头", comment = "ti tou" },
            { text = "剔透", comment = "ti tou" },
            { text = "提头", comment = "ti tou" },
        },
        ["ti tou dao"] = {
            { text = "剃头刀", comment = "ti tou dao" },
        },
        ["ti tuo"] = {
            { text = "提托", comment = "ti tuo" },
        },
        ["ti xu e"] = {
            { text = "体恤额", comment = "ti xu e" },
        },
        ["ti xue"] = {
            { text = "体恤", comment = "ti xue" },
            { text = "啼血", comment = "ti xue" },
        },
        ["tian ao"] = {
            { text = "天奥", comment = "tian ao" },
            { text = "天傲", comment = "tian ao" },
        },
        ["tian bu"] = {
            { text = "填补", comment = "tian bu" },
            { text = "添补", comment = "tian bu" },
            { text = "填不", comment = "tian bu" },
            { text = "天不", comment = "tian bu" },
            { text = "田部", comment = "tian bu" },
            { text = "天补", comment = "tian bu" },
            { text = "田埠", comment = "tian bu" },
        },
        ["tian di"] = {
            { text = "天地", comment = "tian di" },
            { text = "田地", comment = "tian di" },
            { text = "天帝", comment = "tian di" },
            { text = "天敌", comment = "tian di" },
            { text = "田迪", comment = "tian di" },
            { text = "天第", comment = "tian di" },
        },
        ["tian ei"] = {
            { text = "天诶", comment = "tian ei" },
        },
        ["tian fo"] = {
            { text = "天佛", comment = "tian fo" },
        },
        ["tian hua ban"] = {
            { text = "天花板", comment = "tian hua ban" },
        },
        ["tian huai"] = {
            { text = "天淮", comment = "tian huai" },
        },
        ["tian ou"] = {
            { text = "天欧", comment = "tian ou" },
        },
        ["tian ri"] = {
            { text = "天日", comment = "tian ri" },
        },
        ["tian ri an"] = {
            { text = "天日安", comment = "tian ri an" },
        },
        ["tie"] = {
            { text = "贴", comment = "tie" },
            { text = "铁", comment = "tie" },
            { text = "帖", comment = "tie" },
            { text = "萜", comment = "tie" },
            { text = "餮", comment = "tie" },
            { text = "锇", comment = "tie" },
        },
        ["tie a"] = {
            { text = "贴啊", comment = "tie a" },
        },
        ["tie an"] = {
            { text = "铁案", comment = "tie an" },
            { text = "铁安", comment = "tie an" },
        },
        ["tie ao"] = {
            { text = "铁奥", comment = "tie ao" },
        },
        ["tie bu"] = {
            { text = "贴补", comment = "tie bu" },
            { text = "贴布", comment = "tie bu" },
        },
        ["tie fo"] = {
            { text = "铁佛", comment = "tie fo" },
        },
        ["tie ou"] = {
            { text = "铁鸥", comment = "tie ou" },
        },
        ["tie wo"] = {
            { text = "贴我", comment = "tie wo" },
        },
        ["ting a"] = {
            { text = "听啊", comment = "ting a" },
        },
        ["ting ai"] = {
            { text = "挺爱", comment = "ting ai" },
        },
        ["ting ao"] = {
            { text = "听奥", comment = "ting ao" },
        },
        ["ting bu"] = {
            { text = "听不", comment = "ting bu" },
            { text = "挺不", comment = "ting bu" },
            { text = "汀步", comment = "ting bu" },
            { text = "停步", comment = "ting bu" },
        },
        ["ting bu dao"] = {
            { text = "听不到", comment = "ting bu dao" },
        },
        ["ting e"] = {
            { text = "听哦", comment = "ting e" },
        },
        ["ting fo"] = {
            { text = "听佛", comment = "ting fo" },
        },
        ["ting huai"] = {
            { text = "挺坏", comment = "ting huai" },
        },
        ["ting ri"] = {
            { text = "听日", comment = "ting ri" },
            { text = "厅日", comment = "ting ri" },
        },
        ["ting wo"] = {
            { text = "听我", comment = "ting wo" },
        },
        ["ting ye"] = {
            { text = "停业", comment = "ting ye" },
            { text = "听也", comment = "ting ye" },
        },
        ["tong ao"] = {
            { text = "同奥", comment = "tong ao" },
        },
        ["tong bu"] = {
            { text = "同步", comment = "tong bu" },
            { text = "痛不", comment = "tong bu" },
            { text = "通补", comment = "tong bu" },
        },
        ["tong fo"] = {
            { text = "铜佛", comment = "tong fo" },
        },
        ["tong ou"] = {
            { text = "痛殴", comment = "tong ou" },
        },
        ["tou yi tou"] = {
            { text = "投一投", comment = "tou yi tou" },
            { text = "透一透", comment = "tou yi tou" },
        },
        ["tou ying bu"] = {
            { text = "投影布", comment = "tou ying bu" },
        },
        ["tu ao"] = {
            { text = "凸凹", comment = "tu ao" },
            { text = "土澳", comment = "tu ao" },
        },
        ["tu ban"] = {
            { text = "图斑", comment = "tu ban" },
            { text = "图版", comment = "tu ban" },
            { text = "凸版", comment = "tu ban" },
            { text = "图板", comment = "tu ban" },
            { text = "涂板", comment = "tu ban" },
            { text = "屠版", comment = "tu ban" },
        },
        ["tu bao"] = {
            { text = "土包", comment = "tu bao" },
            { text = "图包", comment = "tu bao" },
            { text = "凸包", comment = "tu bao" },
            { text = "兔宝", comment = "tu bao" },
            { text = "图报", comment = "tu bao" },
            { text = "兔包", comment = "tu bao" },
        },
        ["tu bie"] = {
            { text = "土鳖", comment = "tu bie" },
            { text = "图别", comment = "tu bie" },
        },
        ["tu bin"] = {
            { text = "涂斌", comment = "tu bin" },
        },
        ["tu bu"] = {
            { text = "徒步", comment = "tu bu" },
            { text = "涂布", comment = "tu bu" },
            { text = "土布", comment = "tu bu" },
        },
        ["tu fo"] = {
            { text = "涂佛", comment = "tu fo" },
        },
        ["tu hua bu"] = {
            { text = "图画簿", comment = "tu hua bu" },
        },
        ["tu nei"] = {
            { text = "图内", comment = "tu nei" },
        },
        ["tu ou"] = {
            { text = "土偶", comment = "tu ou" },
        },
        ["tu rou"] = {
            { text = "兔肉", comment = "tu rou" },
        },
        ["tu ya"] = {
            { text = "涂鸦", comment = "tu ya" },
            { text = "图雅", comment = "tu ya" },
            { text = "兔牙", comment = "tu ya" },
            { text = "土鸭", comment = "tu ya" },
        },
        ["tu yan"] = {
            { text = "吐艳", comment = "tu yan" },
            { text = "突眼", comment = "tu yan" },
        },
        ["tu yin"] = {
            { text = "涂银", comment = "tu yin" },
            { text = "吐音", comment = "tu yin" },
            { text = "凸印", comment = "tu yin" },
            { text = "土音", comment = "tu yin" },
        },
        ["tu you"] = {
            { text = "涂油", comment = "tu you" },
            { text = "途游", comment = "tu you" },
            { text = "土右", comment = "tu you" },
            { text = "屠幼", comment = "tu you" },
            { text = "兔友", comment = "tu you" },
        },
        ["tu yuan"] = {
            { text = "图元", comment = "tu yuan" },
            { text = "土元", comment = "tu yuan" },
            { text = "图源", comment = "tu yuan" },
            { text = "凸缘", comment = "tu yuan" },
            { text = "途远", comment = "tu yuan" },
            { text = "屠园", comment = "tu yuan" },
            { text = "图元", comment = "tu yuan" },
            { text = "土元", comment = "tu yuan" },
            { text = "图源", comment = "tu yuan" },
            { text = "凸缘", comment = "tu yuan" },
            { text = "途远", comment = "tu yuan" },
            { text = "屠园", comment = "tu yuan" },
        },
        ["tu yue"] = {
            { text = "途岳", comment = "tu yue" },
            { text = "途越", comment = "tu yue" },
        },
        ["tui a"] = {
            { text = "推啊", comment = "tui a" },
        },
        ["tui an"] = {
            { text = "推按", comment = "tui an" },
            { text = "退案", comment = "tui an" },
        },
        ["tui bu"] = {
            { text = "退步", comment = "tui bu" },
            { text = "腿部", comment = "tui bu" },
            { text = "退不", comment = "tui bu" },
            { text = "退补", comment = "tui bu" },
            { text = "退布", comment = "tui bu" },
            { text = "忒不", comment = "tui bu" },
        },
        ["tui ne"] = {
            { text = "退呢", comment = "tui ne" },
        },
        ["tui ou"] = {
            { text = "退欧", comment = "tui ou" },
            { text = "退欧", comment = "tui ou" },
        },
        ["tui xu"] = {
            { text = "推许", comment = "tui xu" },
        },
        ["tui yu"] = {
            { text = "腿与", comment = "tui yu" },
        },
        ["tun di"] = {
            { text = "囤地", comment = "tun di" },
        },
        ["tuo an"] = {
            { text = "脱氨", comment = "tuo an" },
            { text = "拓安", comment = "tuo an" },
        },
        ["tuo bu"] = {
            { text = "拖布", comment = "tuo bu" },
            { text = "拓步", comment = "tuo bu" },
            { text = "妥布", comment = "tuo bu" },
        },
        ["tuo fo"] = {
            { text = "托佛", comment = "tuo fo" },
        },
        ["tuo ou"] = {
            { text = "脱欧", comment = "tuo ou" },
        },
        ["tuo ye"] = {
            { text = "唾液", comment = "tuo ye" },
            { text = "托业", comment = "tuo ye" },
            { text = "拖曳", comment = "tuo ye" },
            { text = "拓野", comment = "tuo ye" },
            { text = "托叶", comment = "tuo ye" },
        },
        ["tuo yu"] = {
            { text = "托育", comment = "tuo yu" },
            { text = "脱狱", comment = "tuo yu" },
            { text = "拓宇", comment = "tuo yu" },
            { text = "脱羽", comment = "tuo yu" },
            { text = "唾余", comment = "tuo yu" },
        },
        ["wa bu"] = {
            { text = "挖补", comment = "wa bu" },
        },
        ["wa na"] = {
            { text = "腽肭", comment = "wa na" },
        },
        ["wa ou"] = {
            { text = "哇偶", comment = "wa ou" },
            { text = "挖偶", comment = "wa ou" },
            { text = "挖藕", comment = "wa ou" },
        },
        ["wa ta"] = {
            { text = "瓦塔", comment = "wa ta" },
        },
        ["wa tang"] = {
            { text = "瓦塘", comment = "wa tang" },
        },
        ["wa tao"] = {
            { text = "袜套", comment = "wa tao" },
        },
        ["wa te"] = {
            { text = "瓦特", comment = "wa te" },
        },
        ["wa tie"] = {
            { text = "挖铁", comment = "wa tie" },
        },
        ["wa tou"] = {
            { text = "瓦头", comment = "wa tou" },
            { text = "袜头", comment = "wa tou" },
        },
        ["wa tuan"] = {
            { text = "蛙团", comment = "wa tuan" },
        },
        ["wa yao"] = {
            { text = "瓦窑", comment = "wa yao" },
        },
        ["wa you"] = {
            { text = "娃友", comment = "wa you" },
        },
        ["wa yun"] = {
            { text = "挖运", comment = "wa yun" },
        },
        ["wai ao"] = {
            { text = "外奥", comment = "wai ao" },
        },
        ["wai bu"] = {
            { text = "外部", comment = "wai bu" },
            { text = "外埠", comment = "wai bu" },
            { text = "外补", comment = "wai bu" },
            { text = "外埔", comment = "wai bu" },
        },
        ["wai huai"] = {
            { text = "外踝", comment = "wai huai" },
            { text = "歪坏", comment = "wai huai" },
        },
        ["wai nv"] = {
            { text = "外女", comment = "wai nv" },
        },
        ["wai ri"] = {
            { text = "歪日", comment = "wai ri" },
            { text = "外日", comment = "wai ri" },
        },
        ["wan a"] = {
            { text = "玩啊", comment = "wan a" },
            { text = "晚啊", comment = "wan a" },
        },
        ["wan a an"] = {
            { text = "玩啊按", comment = "wan a an" },
        },
        ["wan bu"] = {
            { text = "玩不", comment = "wan bu" },
            { text = "腕部", comment = "wan bu" },
            { text = "万步", comment = "wan bu" },
            { text = "万部", comment = "wan bu" },
        },
        ["wan fan"] = {
            { text = "晚饭", comment = "wan fan" },
            { text = "完饭", comment = "wan fan" },
            { text = "碗饭", comment = "wan fan" },
            { text = "晚返", comment = "wan fan" },
        },
        ["wan ou"] = {
            { text = "玩偶", comment = "wan ou" },
            { text = "万欧", comment = "wan ou" },
        },
        ["wang a"] = {
            { text = "网啊", comment = "wang a" },
        },
        ["wang ang"] = {
            { text = "王昂", comment = "wang ang" },
        },
        ["wang ao"] = {
            { text = "王奥", comment = "wang ao" },
            { text = "王傲", comment = "wang ao" },
            { text = "王澳", comment = "wang ao" },
        },
        ["wang bu"] = {
            { text = "网布", comment = "wang bu" },
            { text = "王部", comment = "wang bu" },
            { text = "汪部", comment = "wang bu" },
            { text = "望埠", comment = "wang bu" },
            { text = "网部", comment = "wang bu" },
        },
        ["wang e"] = {
            { text = "王娥", comment = "wang e" },
        },
        ["wang huai"] = {
            { text = "忘怀", comment = "wang huai" },
            { text = "王怀", comment = "wang huai" },
            { text = "王槐", comment = "wang huai" },
        },
        ["wang jia nan"] = {
            { text = "王佳楠", comment = "wang jia nan" },
            { text = "王嘉男", comment = "wang jia nan" },
        },
        ["wang jian an"] = {
            { text = "王建安", comment = "wang jian an" },
        },
        ["wang ou"] = {
            { text = "王鸥", comment = "wang ou" },
            { text = "王欧", comment = "wang ou" },
        },
        ["wang qi e"] = {
            { text = "王企鹅", comment = "wang qi e" },
        },
        ["wang qie"] = {
            { text = "网切", comment = "wang qie" },
        },
        ["wang ri"] = {
            { text = "往日", comment = "wang ri" },
            { text = "望日", comment = "wang ri" },
        },
        ["wang xu"] = {
            { text = "王旭", comment = "wang xu" },
            { text = "汪旭", comment = "wang xu" },
            { text = "王绪", comment = "wang xu" },
            { text = "王许", comment = "wang xu" },
            { text = "王煦", comment = "wang xu" },
            { text = "王栩", comment = "wang xu" },
            { text = "王徐", comment = "wang xu" },
            { text = "王序", comment = "wang xu" },
            { text = "王续", comment = "wang xu" },
            { text = "王诩", comment = "wang xu" },
        },
        ["wang ye"] = {
            { text = "网页", comment = "wang ye" },
            { text = "王爷", comment = "wang ye" },
            { text = "王也", comment = "wang ye" },
            { text = "王野", comment = "wang ye" },
            { text = "王烨", comment = "wang ye" },
            { text = "王叶", comment = "wang ye" },
            { text = "王晔", comment = "wang ye" },
            { text = "网业", comment = "wang ye" },
            { text = "王业", comment = "wang ye" },
            { text = "旺业", comment = "wang ye" },
            { text = "王冶", comment = "wang ye" },
        },
        ["wang yu de"] = {
            { text = "王玉德", comment = "wang yu de" },
            { text = "王玉德", comment = "wang yu de" },
        },
        ["wang yue e"] = {
            { text = "王月娥", comment = "wang yue e" },
            { text = "王月娥", comment = "wang yue e" },
        },
        ["wei bu"] = {
            { text = "尾部", comment = "wei bu" },
            { text = "胃部", comment = "wei bu" },
            { text = "未补", comment = "wei bu" },
            { text = "围布", comment = "wei bu" },
            { text = "未卜", comment = "wei bu" },
            { text = "微步", comment = "wei bu" },
            { text = "围捕", comment = "wei bu" },
            { text = "味部", comment = "wei bu" },
            { text = "魏部", comment = "wei bu" },
            { text = "为不", comment = "wei bu" },
        },
        ["wei ji dan"] = {
            { text = "违纪单", comment = "wei ji dan" },
        },
        ["wei jie an"] = {
            { text = "未结案", comment = "wei jie an" },
        },
        ["wei ou"] = {
            { text = "围殴", comment = "wei ou" },
            { text = "维欧", comment = "wei ou" },
        },
        ["wen hua bu"] = {
            { text = "文化部", comment = "wen hua bu" },
        },
        ["wen rou"] = {
            { text = "温柔", comment = "wen rou" },
        },
        ["wen ru yan"] = {
            { text = "温如言", comment = "wen ru yan" },
        },
        ["wen rui an"] = {
            { text = "温瑞安", comment = "wen rui an" },
        },
        ["wo ao"] = {
            { text = "我熬", comment = "wo ao" },
        },
        ["wo bu xiang"] = {
            { text = "我不想", comment = "wo bu xiang" },
            { text = "我不像", comment = "wo bu xiang" },
        },
        ["wo di"] = {
            { text = "我弟", comment = "wo di" },
            { text = "卧底", comment = "wo di" },
            { text = "我地", comment = "wo di" },
            { text = "我滴", comment = "wo di" },
            { text = "我哋", comment = "wo di" },
            { text = "我睇", comment = "wo di" },
            { text = "沃迪", comment = "wo di" },
        },
        ["wo ei"] = {
            { text = "我诶", comment = "wo ei" },
        },
        ["wo fo"] = {
            { text = "我佛", comment = "wo fo" },
            { text = "卧佛", comment = "wo fo" },
        },
        ["wo huai"] = {
            { text = "我坏", comment = "wo huai" },
        },
        ["wo ou xiang"] = {
            { text = "我偶像", comment = "wo ou xiang" },
        },
        ["wo ri"] = {
            { text = "沃日", comment = "wo ri" },
            { text = "我日", comment = "wo ri" },
        },
        ["wu ao"] = {
            { text = "呜嗷", comment = "wu ao" },
            { text = "兀傲", comment = "wu ao" },
        },
        ["wu bu"] = {
            { text = "五部", comment = "wu bu" },
            { text = "无不", comment = "wu bu" },
            { text = "舞步", comment = "wu bu" },
            { text = "五步", comment = "wu bu" },
            { text = "无补", comment = "wu bu" },
            { text = "乌布", comment = "wu bu" },
        },
        ["wu fo"] = {
            { text = "五佛", comment = "wu fo" },
        },
        ["wu huai"] = {
            { text = "吴怀", comment = "wu huai" },
        },
        ["wu jia nan"] = {
            { text = "吴佳楠", comment = "wu jia nan" },
        },
        ["wu jian an"] = {
            { text = "吴建安", comment = "wu jian an" },
        },
        ["wu ou"] = {
            { text = "无偶", comment = "wu ou" },
        },
        ["wu ri"] = {
            { text = "五日", comment = "wu ri" },
            { text = "乌日", comment = "wu ri" },
            { text = "无日", comment = "wu ri" },
        },
        ["xi ao"] = {
            { text = "西奥", comment = "xi ao" },
            { text = "西澳", comment = "xi ao" },
        },
        ["xi bu"] = {
            { text = "西部", comment = "xi bu" },
            { text = "细部", comment = "xi bu" },
            { text = "系部", comment = "xi bu" },
            { text = "膝部", comment = "xi bu" },
            { text = "细布", comment = "xi bu" },
            { text = "西堡", comment = "xi bu" },
            { text = "西补", comment = "xi bu" },
        },
        ["xi bu qi"] = {
            { text = "洗不起", comment = "xi bu qi" },
        },
        ["xi da"] = {
            { text = "西大", comment = "xi da" },
            { text = "希达", comment = "xi da" },
            { text = "西达", comment = "xi da" },
            { text = "喜达", comment = "xi da" },
            { text = "悉大", comment = "xi da" },
        },
        ["xi dai"] = {
            { text = "细带", comment = "xi dai" },
            { text = "惜贷", comment = "xi dai" },
        },
        ["xi dan"] = {
            { text = "西单", comment = "xi dan" },
            { text = "喜蛋", comment = "xi dan" },
            { text = "奚丹", comment = "xi dan" },
            { text = "戏单", comment = "xi dan" },
        },
        ["xi dao"] = {
            { text = "铣刀", comment = "xi dao" },
            { text = "洗到", comment = "xi dao" },
            { text = "吸到", comment = "xi dao" },
            { text = "西道", comment = "xi dao" },
            { text = "西岛", comment = "xi dao" },
            { text = "戏导", comment = "xi dao" },
        },
        ["xi de"] = {
            { text = "洗的", comment = "xi de" },
            { text = "细的", comment = "xi de" },
            { text = "习得", comment = "xi de" },
            { text = "稀得", comment = "xi de" },
            { text = "喜得", comment = "xi de" },
            { text = "吸得", comment = "xi de" },
            { text = "西德", comment = "xi de" },
            { text = "系的", comment = "xi de" },
            { text = "洗得", comment = "xi de" },
            { text = "喜德", comment = "xi de" },
            { text = "戏的", comment = "xi de" },
            { text = "希德", comment = "xi de" },
        },
        ["xi di"] = {
            { text = "洗涤", comment = "xi di" },
            { text = "洗地", comment = "xi di" },
            { text = "西地", comment = "xi di" },
            { text = "西堤", comment = "xi di" },
            { text = "悉地", comment = "xi di" },
            { text = "西递", comment = "xi di" },
            { text = "喜地", comment = "xi di" },
            { text = "席地", comment = "xi di" },
            { text = "洗底", comment = "xi di" },
            { text = "细弟", comment = "xi di" },
            { text = "西帝", comment = "xi di" },
            { text = "希地", comment = "xi di" },
            { text = "西迪", comment = "xi di" },
            { text = "隙地", comment = "xi di" },
            { text = "喜滴", comment = "xi di" },
        },
        ["xi di ye"] = {
            { text = "洗涤液", comment = "xi di ye" },
        },
        ["xi die"] = {
            { text = "戏蝶", comment = "xi die" },
        },
        ["xi duan"] = {
            { text = "西段", comment = "xi duan" },
            { text = "西端", comment = "xi duan" },
        },
        ["xi duo"] = {
            { text = "喜多", comment = "xi duo" },
            { text = "戏多", comment = "xi duo" },
            { text = "西多", comment = "xi duo" },
        },
        ["xi ei"] = {
            { text = "系诶", comment = "xi ei" },
        },
        ["xi er"] = {
            { text = "希尔", comment = "xi er" },
            { text = "西二", comment = "xi er" },
            { text = "希儿", comment = "xi er" },
            { text = "喜儿", comment = "xi er" },
            { text = "洗耳", comment = "xi er" },
            { text = "西尔", comment = "xi er" },
            { text = "熙儿", comment = "xi er" },
            { text = "曦儿", comment = "xi er" },
            { text = "兮儿", comment = "xi er" },
            { text = "汐儿", comment = "xi er" },
            { text = "茜儿", comment = "xi er" },
        },
        ["xi er an"] = {
            { text = "希尔安", comment = "xi er an" },
        },
        ["xi fo"] = {
            { text = "西佛", comment = "xi fo" },
        },
        ["xi huai"] = {
            { text = "洗坏", comment = "xi huai" },
        },
        ["xi na"] = {
            { text = "吸纳", comment = "xi na" },
            { text = "希娜", comment = "xi na" },
            { text = "喜娜", comment = "xi na" },
            { text = "西纳", comment = "xi na" },
        },
        ["xi nai"] = {
            { text = "吸奶", comment = "xi nai" },
            { text = "西奈", comment = "xi nai" },
        },
        ["xi nan"] = {
            { text = "西南", comment = "xi nan" },
            { text = "溪南", comment = "xi nan" },
            { text = "西囡", comment = "xi nan" },
        },
        ["xi nan bu"] = {
            { text = "西南部", comment = "xi nan bu" },
        },
        ["xi nan cun"] = {
            { text = "西南村", comment = "xi nan cun" },
        },
        ["xi nan jie"] = {
            { text = "西南街", comment = "xi nan jie" },
        },
        ["xi nan jie dao"] = {
            { text = "西南街道", comment = "xi nan jie dao" },
        },
        ["xi nan lu"] = {
            { text = "西南路", comment = "xi nan lu" },
        },
        ["xi nang"] = {
            { text = "傒囊", comment = "xi nang" },
        },
        ["xi nao"] = {
            { text = "洗脑", comment = "xi nao" },
            { text = "嬉闹", comment = "xi nao" },
        },
        ["xi nei"] = {
            { text = "西内", comment = "xi nei" },
            { text = "系内", comment = "xi nei" },
        },
        ["xi nen"] = {
            { text = "细嫩", comment = "xi nen" },
        },
        ["xi niu"] = {
            { text = "犀牛", comment = "xi niu" },
            { text = "西牛", comment = "xi niu" },
            { text = "喜牛", comment = "xi niu" },
            { text = "希牛", comment = "xi niu" },
        },
        ["xi nuan"] = {
            { text = "喜暖", comment = "xi nuan" },
        },
        ["xi nuo"] = {
            { text = "希诺", comment = "xi nuo" },
            { text = "西诺", comment = "xi nuo" },
        },
        ["xi nuo de"] = {
            { text = "西诺德", comment = "xi nuo de" },
        },
        ["xi ou"] = {
            { text = "西欧", comment = "xi ou" },
        },
        ["xi ou qi"] = {
            { text = "吸欧气", comment = "xi ou qi" },
        },
        ["xi ri"] = {
            { text = "昔日", comment = "xi ri" },
            { text = "夕日", comment = "xi ri" },
        },
        ["xi ta"] = {
            { text = "西塔", comment = "xi ta" },
        },
        ["xi tai"] = {
            { text = "戏台", comment = "xi tai" },
            { text = "西台", comment = "xi tai" },
            { text = "西太", comment = "xi tai" },
            { text = "熙泰", comment = "xi tai" },
            { text = "西泰", comment = "xi tai" },
        },
        ["xi tan"] = {
            { text = "细谈", comment = "xi tan" },
            { text = "吸痰", comment = "xi tan" },
            { text = "西滩", comment = "xi tan" },
            { text = "西坦", comment = "xi tan" },
        },
        ["xi tang"] = {
            { text = "喜糖", comment = "xi tang" },
            { text = "西塘", comment = "xi tang" },
            { text = "西棠", comment = "xi tang" },
            { text = "喜堂", comment = "xi tang" },
            { text = "西唐", comment = "xi tang" },
        },
        ["xi tao"] = {
            { text = "西陶", comment = "xi tao" },
            { text = "喜涛", comment = "xi tao" },
        },
        ["xi tie"] = {
            { text = "喜帖", comment = "xi tie" },
            { text = "西铁", comment = "xi tie" },
        },
        ["xi tie jie"] = {
            { text = "喜帖街", comment = "xi tie jie" },
        },
        ["xi tou"] = {
            { text = "洗头", comment = "xi tou" },
            { text = "西头", comment = "xi tou" },
            { text = "吸头", comment = "xi tou" },
            { text = "溪头", comment = "xi tou" },
            { text = "西投", comment = "xi tou" },
            { text = "膝头", comment = "xi tou" },
        },
        ["xi tou tou"] = {
            { text = "洗头头", comment = "xi tou tou" },
        },
        ["xi tuan"] = {
            { text = "喜团", comment = "xi tuan" },
            { text = "西团", comment = "xi tuan" },
        },
        ["xi wa"] = {
            { text = "西瓦", comment = "xi wa" },
            { text = "希瓦", comment = "xi wa" },
            { text = "喜娃", comment = "xi wa" },
            { text = "细娃", comment = "xi wa" },
        },
        ["xi wai"] = {
            { text = "西外", comment = "xi wai" },
            { text = "戏外", comment = "xi wai" },
        },
        ["xi wan"] = {
            { text = "洗完", comment = "xi wan" },
            { text = "洗碗", comment = "xi wan" },
            { text = "吸完", comment = "xi wan" },
            { text = "西湾", comment = "xi wan" },
            { text = "西万", comment = "xi wan" },
            { text = "喜玩", comment = "xi wan" },
        },
        ["xi wan lu"] = {
            { text = "西湾路", comment = "xi wan lu" },
        },
        ["xi wei"] = {
            { text = "细微", comment = "xi wei" },
            { text = "席位", comment = "xi wei" },
            { text = "洗胃", comment = "xi wei" },
            { text = "熹微", comment = "xi wei" },
            { text = "西威", comment = "xi wei" },
            { text = "系未", comment = "xi wei" },
            { text = "膝围", comment = "xi wei" },
            { text = "西魏", comment = "xi wei" },
            { text = "溪尾", comment = "xi wei" },
            { text = "席伟", comment = "xi wei" },
            { text = "喜威", comment = "xi wei" },
            { text = "细伟", comment = "xi wei" },
            { text = "西尾", comment = "xi wei" },
            { text = "西维", comment = "xi wei" },
            { text = "希伟", comment = "xi wei" },
        },
        ["xi wen"] = {
            { text = "细纹", comment = "xi wen" },
            { text = "细问", comment = "xi wen" },
            { text = "西文", comment = "xi wen" },
            { text = "希文", comment = "xi wen" },
            { text = "檄文", comment = "xi wen" },
            { text = "戏文", comment = "xi wen" },
            { text = "习文", comment = "xi wen" },
            { text = "熙雯", comment = "xi wen" },
            { text = "曦文", comment = "xi wen" },
            { text = "席文", comment = "xi wen" },
            { text = "熙文", comment = "xi wen" },
            { text = "喜闻", comment = "xi wen" },
            { text = "喜文", comment = "xi wen" },
        },
        ["xi yi bu"] = {
            { text = "洗衣部", comment = "xi yi bu" },
        },
        ["xi yi ou"] = {
            { text = "希艺欧", comment = "xi yi ou" },
        },
        ["xia ba"] = {
            { text = "下吧", comment = "xia ba" },
            { text = "下巴", comment = "xia ba" },
            { text = "下把", comment = "xia ba" },
            { text = "下坝", comment = "xia ba" },
            { text = "下八", comment = "xia ba" },
        },
        ["xia bai"] = {
            { text = "下摆", comment = "xia bai" },
            { text = "瞎掰", comment = "xia bai" },
            { text = "下白", comment = "xia bai" },
            { text = "下柏", comment = "xia bai" },
            { text = "夏白", comment = "xia bai" },
        },
        ["xia bai hua"] = {
            { text = "瞎白话", comment = "xia bai hua" },
        },
        ["xia ban"] = {
            { text = "下班", comment = "xia ban" },
            { text = "下半", comment = "xia ban" },
            { text = "下板", comment = "xia ban" },
            { text = "下坂", comment = "xia ban" },
        },
        ["xia ban ban"] = {
            { text = "下班班", comment = "xia ban ban" },
        },
        ["xia ban qi"] = {
            { text = "下半旗", comment = "xia ban qi" },
        },
        ["xia ban zi"] = {
            { text = "下绊子", comment = "xia ban zi" },
        },
        ["xia bang"] = {
            { text = "夏邦", comment = "xia bang" },
            { text = "下帮", comment = "xia bang" },
        },
        ["xia bao"] = {
            { text = "下包", comment = "xia bao" },
            { text = "瞎报", comment = "xia bao" },
            { text = "虾堡", comment = "xia bao" },
            { text = "夏宝", comment = "xia bao" },
            { text = "下堡", comment = "xia bao" },
            { text = "霞宝", comment = "xia bao" },
            { text = "下保", comment = "xia bao" },
        },
        ["xia bei"] = {
            { text = "下呗", comment = "xia bei" },
            { text = "夏被", comment = "xia bei" },
            { text = "下辈", comment = "xia bei" },
            { text = "夏北", comment = "xia bei" },
            { text = "下北", comment = "xia bei" },
        },
        ["xia ben"] = {
            { text = "下本", comment = "xia ben" },
        },
        ["xia bin"] = {
            { text = "夏斌", comment = "xia bin" },
            { text = "夏彬", comment = "xia bin" },
        },
        ["xia bu"] = {
            { text = "下部", comment = "xia bu" },
            { text = "下步", comment = "xia bu" },
            { text = "下不", comment = "xia bu" },
            { text = "呷哺", comment = "xia bu" },
            { text = "峡部", comment = "xia bu" },
            { text = "夏布", comment = "xia bu" },
            { text = "下埠", comment = "xia bu" },
            { text = "下布", comment = "xia bu" },
            { text = "夏部", comment = "xia bu" },
        },
        ["xia huai"] = {
            { text = "吓坏", comment = "xia huai" },
            { text = "下怀", comment = "xia huai" },
        },
        ["xia nai"] = {
            { text = "下奶", comment = "xia nai" },
            { text = "瞎奶", comment = "xia nai" },
        },
        ["xia nan"] = {
            { text = "夏楠", comment = "xia nan" },
            { text = "下南", comment = "xia nan" },
            { text = "夏南", comment = "xia nan" },
            { text = "虾男", comment = "xia nan" },
        },
        ["xia ne"] = {
            { text = "下呢", comment = "xia ne" },
        },
        ["xia nei"] = {
            { text = "辖内", comment = "xia nei" },
        },
        ["xia nin"] = {
            { text = "下您", comment = "xia nin" },
        },
        ["xia niu"] = {
            { text = "下牛", comment = "xia niu" },
        },
        ["xia nuo"] = {
            { text = "夏诺", comment = "xia nuo" },
        },
        ["xia o"] = {
            { text = "下哦", comment = "xia o" },
        },
        ["xia ou"] = {
            { text = "夏鸥", comment = "xia ou" },
        },
        ["xia ri"] = {
            { text = "夏日", comment = "xia ri" },
        },
        ["xia ta"] = {
            { text = "下塔", comment = "xia ta" },
            { text = "下他", comment = "xia ta" },
            { text = "下榻", comment = "xia ta" },
            { text = "吓他", comment = "xia ta" },
            { text = "夏塔", comment = "xia ta" },
        },
        ["xia tai"] = {
            { text = "下台", comment = "xia tai" },
        },
        ["xia tan"] = {
            { text = "下探", comment = "xia tan" },
            { text = "侠探", comment = "xia tan" },
        },
        ["xia tao"] = {
            { text = "下套", comment = "xia tao" },
            { text = "夏涛", comment = "xia tao" },
        },
        ["xia tie"] = {
            { text = "下帖", comment = "xia tie" },
            { text = "下铁", comment = "xia tie" },
        },
        ["xia tou"] = {
            { text = "下头", comment = "xia tou" },
            { text = "虾头", comment = "xia tou" },
        },
        ["xia tuan"] = {
            { text = "下团", comment = "xia tuan" },
        },
        ["xia tuo"] = {
            { text = "下托", comment = "xia tuo" },
        },
        ["xian ai"] = {
            { text = "腺癌", comment = "xian ai" },
            { text = "现爱", comment = "xian ai" },
            { text = "险隘", comment = "xian ai" },
        },
        ["xian an"] = {
            { text = "先按", comment = "xian an" },
            { text = "酰胺", comment = "xian an" },
            { text = "咸安", comment = "xian an" },
            { text = "现案", comment = "xian an" },
        },
        ["xian bu"] = {
            { text = "先不", comment = "xian bu" },
            { text = "先补", comment = "xian bu" },
        },
        ["xian di"] = {
            { text = "贤弟", comment = "xian di" },
            { text = "现地", comment = "xian di" },
            { text = "先帝", comment = "xian di" },
            { text = "仙帝", comment = "xian di" },
            { text = "献帝", comment = "xian di" },
            { text = "险地", comment = "xian di" },
            { text = "仙蒂", comment = "xian di" },
            { text = "县底", comment = "xian di" },
        },
        ["xian e"] = {
            { text = "限额", comment = "xian e" },
            { text = "险恶", comment = "xian e" },
            { text = "咸鹅", comment = "xian e" },
        },
        ["xian huai"] = {
            { text = "显怀", comment = "xian huai" },
        },
        ["xian ou"] = {
            { text = "现偶", comment = "xian ou" },
        },
        ["xian ri"] = {
            { text = "闲日", comment = "xian ri" },
        },
        ["xian wo"] = {
            { text = "嫌我", comment = "xian wo" },
        },
        ["xian yu"] = {
            { text = "咸鱼", comment = "xian yu" },
            { text = "闲鱼", comment = "xian yu" },
            { text = "限于", comment = "xian yu" },
            { text = "县域", comment = "xian yu" },
            { text = "仙玉", comment = "xian yu" },
            { text = "先于", comment = "xian yu" },
            { text = "陷于", comment = "xian yu" },
            { text = "鲜鱼", comment = "xian yu" },
            { text = "闲余", comment = "xian yu" },
            { text = "仙域", comment = "xian yu" },
            { text = "鲜于", comment = "xian yu" },
            { text = "鲜语", comment = "xian yu" },
            { text = "仙羽", comment = "xian yu" },
            { text = "先玉", comment = "xian yu" },
            { text = "线与", comment = "xian yu" },
            { text = "仙鱼", comment = "xian yu" },
            { text = "羡余", comment = "xian yu" },
            { text = "咸鱼", comment = "xian yu" },
            { text = "闲鱼", comment = "xian yu" },
            { text = "限于", comment = "xian yu" },
            { text = "县域", comment = "xian yu" },
            { text = "仙玉", comment = "xian yu" },
            { text = "先于", comment = "xian yu" },
            { text = "陷于", comment = "xian yu" },
            { text = "鲜鱼", comment = "xian yu" },
            { text = "闲余", comment = "xian yu" },
            { text = "仙域", comment = "xian yu" },
            { text = "鲜于", comment = "xian yu" },
            { text = "鲜语", comment = "xian yu" },
            { text = "仙羽", comment = "xian yu" },
            { text = "先玉", comment = "xian yu" },
            { text = "线与", comment = "xian yu" },
            { text = "仙鱼", comment = "xian yu" },
            { text = "羡余", comment = "xian yu" },
        },
        ["xiang a"] = {
            { text = "想啊", comment = "xiang a" },
            { text = "香啊", comment = "xiang a" },
        },
        ["xiang ai"] = {
            { text = "相爱", comment = "xiang ai" },
            { text = "想爱", comment = "xiang ai" },
            { text = "乡爱", comment = "xiang ai" },
            { text = "湘爱", comment = "xiang ai" },
        },
        ["xiang an"] = {
            { text = "翔安", comment = "xiang an" },
            { text = "祥安", comment = "xiang an" },
            { text = "详案", comment = "xiang an" },
            { text = "湘安", comment = "xiang an" },
            { text = "香案", comment = "xiang an" },
            { text = "相安", comment = "xiang an" },
            { text = "襄安", comment = "xiang an" },
        },
        ["xiang bu"] = {
            { text = "想不", comment = "xiang bu" },
            { text = "相簿", comment = "xiang bu" },
            { text = "像不", comment = "xiang bu" },
            { text = "想补", comment = "xiang bu" },
            { text = "乡补", comment = "xiang bu" },
        },
        ["xiang fo"] = {
            { text = "向佛", comment = "xiang fo" },
        },
        ["xiang ou"] = {
            { text = "想偶", comment = "xiang ou" },
        },
        ["xiang wo"] = {
            { text = "想我", comment = "xiang wo" },
            { text = "像我", comment = "xiang wo" },
            { text = "向我", comment = "xiang wo" },
            { text = "象我", comment = "xiang wo" },
        },
        ["xiang xu"] = {
            { text = "相许", comment = "xiang xu" },
            { text = "相序", comment = "xiang xu" },
            { text = "相续", comment = "xiang xu" },
            { text = "向旭", comment = "xiang xu" },
            { text = "祥旭", comment = "xiang xu" },
            { text = "庠序", comment = "xiang xu" },
        },
        ["xiang ye"] = {
            { text = "香叶", comment = "xiang ye" },
            { text = "想也", comment = "xiang ye" },
            { text = "乡野", comment = "xiang ye" },
            { text = "祥业", comment = "xiang ye" },
            { text = "相爷", comment = "xiang ye" },
            { text = "翔业", comment = "xiang ye" },
        },
        ["xiao"] = {
            { text = "小", comment = "xiao" },
            { text = "笑", comment = "xiao" },
            { text = "晓", comment = "xiao" },
            { text = "校", comment = "xiao" },
            { text = "消", comment = "xiao" },
            { text = "肖", comment = "xiao" },
            { text = "效", comment = "xiao" },
            { text = "销", comment = "xiao" },
            { text = "孝", comment = "xiao" },
            { text = "萧", comment = "xiao" },
            { text = "削", comment = "xiao" },
            { text = "筱", comment = "xiao" },
            { text = "宵", comment = "xiao" },
            { text = "潇", comment = "xiao" },
            { text = "霄", comment = "xiao" },
            { text = "啸", comment = "xiao" },
            { text = "箫", comment = "xiao" },
            { text = "骁", comment = "xiao" },
            { text = "枭", comment = "xiao" },
            { text = "嚣", comment = "xiao" },
            { text = "硝", comment = "xiao" },
            { text = "逍", comment = "xiao" },
            { text = "皛", comment = "xiao" },
            { text = "哓", comment = "xiao" },
            { text = "哮", comment = "xiao" },
            { text = "魈", comment = "xiao" },
            { text = "虓", comment = "xiao" },
            { text = "绡", comment = "xiao" },
            { text = "淆", comment = "xiao" },
            { text = "崤", comment = "xiao" },
            { text = "鸮", comment = "xiao" },
            { text = "洨", comment = "xiao" },
            { text = "翛", comment = "xiao" },
            { text = "猇", comment = "xiao" },
            { text = "蛸", comment = "xiao" },
            { text = "敩", comment = "xiao" },
            { text = "枵", comment = "xiao" },
            { text = "恔", comment = "xiao" },
            { text = "熇", comment = "xiao" },
            { text = "睄", comment = "xiao" },
            { text = "涍", comment = "xiao" },
            { text = "蟏", comment = "xiao" },
            { text = "䴔", comment = "xiao" },
            { text = "泶", comment = "xiao" },
            { text = "滧", comment = "xiao" },
            { text = "𫍲", comment = "xiao" },
        },
        ["xiao a"] = {
            { text = "小啊", comment = "xiao a" },
            { text = "笑啊", comment = "xiao a" },
        },
        ["xiao a di"] = {
            { text = "小阿迪", comment = "xiao a di" },
        },
        ["xiao ai"] = {
            { text = "小爱", comment = "xiao ai" },
            { text = "小艾", comment = "xiao ai" },
            { text = "小哀", comment = "xiao ai" },
            { text = "晓爱", comment = "xiao ai" },
        },
        ["xiao ai hua"] = {
            { text = "肖爱华", comment = "xiao ai hua" },
        },
        ["xiao an"] = {
            { text = "小安", comment = "xiao an" },
            { text = "销案", comment = "xiao an" },
            { text = "小暗", comment = "xiao an" },
            { text = "消安", comment = "xiao an" },
            { text = "硝铵", comment = "xiao an" },
            { text = "校安", comment = "xiao an" },
            { text = "晓安", comment = "xiao an" },
            { text = "肖安", comment = "xiao an" },
        },
        ["xiao an ban"] = {
            { text = "校安办", comment = "xiao an ban" },
        },
        ["xiao an qi"] = {
            { text = "小安琪", comment = "xiao an qi" },
        },
        ["xiao an zi"] = {
            { text = "小安子", comment = "xiao an zi" },
        },
        ["xiao ang"] = {
            { text = "小昂", comment = "xiao ang" },
        },
        ["xiao ao"] = {
            { text = "笑傲", comment = "xiao ao" },
            { text = "小奥", comment = "xiao ao" },
            { text = "小袄", comment = "xiao ao" },
            { text = "小傲", comment = "xiao ao" },
            { text = "啸傲", comment = "xiao ao" },
            { text = "笑熬", comment = "xiao ao" },
        },
        ["xiao bu"] = {
            { text = "小布", comment = "xiao bu" },
            { text = "小步", comment = "xiao bu" },
            { text = "小卜", comment = "xiao bu" },
            { text = "小不", comment = "xiao bu" },
            { text = "校部", comment = "xiao bu" },
            { text = "小补", comment = "xiao bu" },
            { text = "肖部", comment = "xiao bu" },
            { text = "小部", comment = "xiao bu" },
        },
        ["xiao bu bu"] = {
            { text = "小布布", comment = "xiao bu bu" },
        },
        ["xiao bu ou"] = {
            { text = "小布偶", comment = "xiao bu ou" },
        },
        ["xiao di"] = {
            { text = "小弟", comment = "xiao di" },
            { text = "小迪", comment = "xiao di" },
            { text = "肖迪", comment = "xiao di" },
            { text = "晓迪", comment = "xiao di" },
            { text = "小狄", comment = "xiao di" },
            { text = "小滴", comment = "xiao di" },
            { text = "小笛", comment = "xiao di" },
            { text = "小底", comment = "xiao di" },
            { text = "小娣", comment = "xiao di" },
            { text = "肖笛", comment = "xiao di" },
            { text = "晓娣", comment = "xiao di" },
        },
        ["xiao en"] = {
            { text = "肖恩", comment = "xiao en" },
            { text = "小恩", comment = "xiao en" },
            { text = "晓恩", comment = "xiao en" },
        },
        ["xiao fei"] = {
            { text = "消费", comment = "xiao fei" },
            { text = "小费", comment = "xiao fei" },
            { text = "小飞", comment = "xiao fei" },
            { text = "晓飞", comment = "xiao fei" },
            { text = "小菲", comment = "xiao fei" },
            { text = "肖飞", comment = "xiao fei" },
            { text = "晓菲", comment = "xiao fei" },
            { text = "小肥", comment = "xiao fei" },
            { text = "笑飞", comment = "xiao fei" },
            { text = "小斐", comment = "xiao fei" },
            { text = "小非", comment = "xiao fei" },
            { text = "肖菲", comment = "xiao fei" },
            { text = "晓斐", comment = "xiao fei" },
            { text = "小妃", comment = "xiao fei" },
            { text = "校飞", comment = "xiao fei" },
            { text = "孝飞", comment = "xiao fei" },
            { text = "晓非", comment = "xiao fei" },
            { text = "晓霏", comment = "xiao fei" },
        },
        ["xiao fei e"] = {
            { text = "消费额", comment = "xiao fei e" },
        },
        ["xiao fo"] = {
            { text = "小佛", comment = "xiao fo" },
            { text = "笑佛", comment = "xiao fo" },
        },
        ["xiao fo ye"] = {
            { text = "小佛爷", comment = "xiao fo ye" },
        },
        ["xiao huai"] = {
            { text = "小坏", comment = "xiao huai" },
        },
        ["xiao jia bi yu"] = {
            { text = "小家碧玉", comment = "xiao jia bi yu" },
        },
        ["xiao jiao yin"] = {
            { text = "小脚印", comment = "xiao jiao yin" },
        },
        ["xiao ou"] = {
            { text = "小欧", comment = "xiao ou" },
            { text = "晓鸥", comment = "xiao ou" },
            { text = "小鸥", comment = "xiao ou" },
        },
        ["xiao qi e"] = {
            { text = "小企鹅", comment = "xiao qi e" },
        },
        ["xiao qie"] = {
            { text = "小妾", comment = "xiao qie" },
        },
        ["xiao ri"] = {
            { text = "小日", comment = "xiao ri" },
            { text = "啸日", comment = "xiao ri" },
            { text = "晓日", comment = "xiao ri" },
        },
        ["xiao yu"] = {
            { text = "小于", comment = "xiao yu" },
            { text = "小鱼", comment = "xiao yu" },
            { text = "小雨", comment = "xiao yu" },
            { text = "小宇", comment = "xiao yu" },
            { text = "小玉", comment = "xiao yu" },
            { text = "小余", comment = "xiao yu" },
            { text = "晓宇", comment = "xiao yu" },
            { text = "小俞", comment = "xiao yu" },
            { text = "小羽", comment = "xiao yu" },
            { text = "笑语", comment = "xiao yu" },
            { text = "晓雨", comment = "xiao yu" },
            { text = "小语", comment = "xiao yu" },
            { text = "晓玉", comment = "xiao yu" },
            { text = "小钰", comment = "xiao yu" },
            { text = "肖宇", comment = "xiao yu" },
            { text = "小瑜", comment = "xiao yu" },
            { text = "晓瑜", comment = "xiao yu" },
            { text = "小郁", comment = "xiao yu" },
            { text = "小虞", comment = "xiao yu" },
            { text = "小喻", comment = "xiao yu" },
            { text = "肖雨", comment = "xiao yu" },
            { text = "小禹", comment = "xiao yu" },
            { text = "晓钰", comment = "xiao yu" },
            { text = "肖玉", comment = "xiao yu" },
            { text = "小渔", comment = "xiao yu" },
            { text = "小煜", comment = "xiao yu" },
            { text = "笑宇", comment = "xiao yu" },
            { text = "晓羽", comment = "xiao yu" },
            { text = "筱雨", comment = "xiao yu" },
            { text = "肖瑜", comment = "xiao yu" },
            { text = "小渝", comment = "xiao yu" },
            { text = "小予", comment = "xiao yu" },
            { text = "啸宇", comment = "xiao yu" },
            { text = "小妤", comment = "xiao yu" },
            { text = "小昱", comment = "xiao yu" },
            { text = "笑雨", comment = "xiao yu" },
            { text = "晓煜", comment = "xiao yu" },
            { text = "肖钰", comment = "xiao yu" },
            { text = "萧雨", comment = "xiao yu" },
            { text = "肖羽", comment = "xiao yu" },
            { text = "晓昱", comment = "xiao yu" },
            { text = "晓谕", comment = "xiao yu" },
            { text = "小御", comment = "xiao yu" },
            { text = "小毓", comment = "xiao yu" },
            { text = "晓语", comment = "xiao yu" },
            { text = "小遇", comment = "xiao yu" },
            { text = "萧羽", comment = "xiao yu" },
            { text = "晓喻", comment = "xiao yu" },
            { text = "萧宇", comment = "xiao yu" },
            { text = "霄宇", comment = "xiao yu" },
            { text = "潇雨", comment = "xiao yu" },
            { text = "晓禹", comment = "xiao yu" },
        },
        ["xie a"] = {
            { text = "写啊", comment = "xie a" },
        },
        ["xie ai"] = {
            { text = "谢爱", comment = "xie ai" },
        },
        ["xie an"] = {
            { text = "谢安", comment = "xie an" },
            { text = "协安", comment = "xie an" },
            { text = "歇鞍", comment = "xie an" },
        },
        ["xie ban"] = {
            { text = "协办", comment = "xie ban" },
            { text = "歇班", comment = "xie ban" },
            { text = "斜板", comment = "xie ban" },
        },
        ["xie bu"] = {
            { text = "谢步", comment = "xie bu" },
            { text = "写不", comment = "xie bu" },
        },
        ["xie di"] = {
            { text = "鞋底", comment = "xie di" },
            { text = "谢帝", comment = "xie di" },
            { text = "邪帝", comment = "xie di" },
            { text = "谢迪", comment = "xie di" },
            { text = "泄底", comment = "xie di" },
            { text = "血滴", comment = "xie di" },
        },
        ["xie e"] = {
            { text = "邪恶", comment = "xie e" },
        },
        ["xie ei"] = {
            { text = "写诶", comment = "xie ei" },
        },
        ["xie fo"] = {
            { text = "谢佛", comment = "xie fo" },
        },
        ["xie o"] = {
            { text = "写哦", comment = "xie o" },
        },
        ["xie ou"] = {
            { text = "谢鸥", comment = "xie ou" },
        },
        ["xie wo"] = {
            { text = "谢我", comment = "xie wo" },
            { text = "写我", comment = "xie wo" },
            { text = "歇窝", comment = "xie wo" },
        },
        ["xie xu"] = {
            { text = "些许", comment = "xie xu" },
            { text = "谢旭", comment = "xie xu" },
            { text = "些须", comment = "xie xu" },
        },
        ["xie ye"] = {
            { text = "鞋业", comment = "xie ye" },
            { text = "歇业", comment = "xie ye" },
            { text = "谢烨", comment = "xie ye" },
            { text = "血夜", comment = "xie ye" },
        },
        ["xie yi e"] = {
            { text = "协议额", comment = "xie yi e" },
        },
        ["xin a"] = {
            { text = "心啊", comment = "xin a" },
            { text = "信啊", comment = "xin a" },
        },
        ["xin ai"] = {
            { text = "心爱", comment = "xin ai" },
            { text = "新爱", comment = "xin ai" },
            { text = "芯爱", comment = "xin ai" },
        },
        ["xin an"] = {
            { text = "新安", comment = "xin an" },
            { text = "心安", comment = "xin an" },
            { text = "信安", comment = "xin an" },
            { text = "辛安", comment = "xin an" },
            { text = "鑫安", comment = "xin an" },
            { text = "欣安", comment = "xin an" },
            { text = "新垵", comment = "xin an" },
            { text = "心岸", comment = "xin an" },
        },
        ["xin an bu"] = {
            { text = "信安部", comment = "xin an bu" },
        },
        ["xin an cun"] = {
            { text = "新安村", comment = "xin an cun" },
        },
        ["xin an jie"] = {
            { text = "新安街", comment = "xin an jie" },
        },
        ["xin an jie dao"] = {
            { text = "新安街道", comment = "xin an jie dao" },
        },
        ["xin an lu"] = {
            { text = "新安路", comment = "xin an lu" },
        },
        ["xin ang"] = {
            { text = "新昂", comment = "xin ang" },
        },
        ["xin ao"] = {
            { text = "新奥", comment = "xin ao" },
            { text = "新澳", comment = "xin ao" },
            { text = "鑫奥", comment = "xin ao" },
            { text = "新傲", comment = "xin ao" },
            { text = "欣奥", comment = "xin ao" },
        },
        ["xin bu"] = {
            { text = "信不", comment = "xin bu" },
            { text = "信步", comment = "xin bu" },
            { text = "芯部", comment = "xin bu" },
            { text = "心不", comment = "xin bu" },
            { text = "锌布", comment = "xin bu" },
            { text = "新埠", comment = "xin bu" },
        },
        ["xin di"] = {
            { text = "心底", comment = "xin di" },
            { text = "新低", comment = "xin di" },
            { text = "新地", comment = "xin di" },
            { text = "心地", comment = "xin di" },
            { text = "辛迪", comment = "xin di" },
            { text = "新迪", comment = "xin di" },
            { text = "鑫迪", comment = "xin di" },
            { text = "信地", comment = "xin di" },
            { text = "鑫地", comment = "xin di" },
            { text = "新帝", comment = "xin di" },
            { text = "新堤", comment = "xin di" },
            { text = "欣迪", comment = "xin di" },
            { text = "心迪", comment = "xin di" },
            { text = "信迪", comment = "xin di" },
        },
        ["xin en"] = {
            { text = "芯恩", comment = "xin en" },
        },
        ["xin fo"] = {
            { text = "信佛", comment = "xin fo" },
            { text = "心佛", comment = "xin fo" },
        },
        ["xin huai"] = {
            { text = "心怀", comment = "xin huai" },
            { text = "新淮", comment = "xin huai" },
        },
        ["xin ou"] = {
            { text = "新欧", comment = "xin ou" },
            { text = "新瓯", comment = "xin ou" },
        },
        ["xin ri"] = {
            { text = "新日", comment = "xin ri" },
        },
        ["xin wo"] = {
            { text = "信我", comment = "xin wo" },
            { text = "心窝", comment = "xin wo" },
            { text = "新窝", comment = "xin wo" },
            { text = "新沃", comment = "xin wo" },
            { text = "鑫沃", comment = "xin wo" },
            { text = "信沃", comment = "xin wo" },
        },
        ["xin wo de"] = {
            { text = "信我的", comment = "xin wo de" },
        },
        ["xin xu"] = {
            { text = "心虚", comment = "xin xu" },
            { text = "心绪", comment = "xin xu" },
            { text = "新圩", comment = "xin xu" },
            { text = "新旭", comment = "xin xu" },
            { text = "鑫旭", comment = "xin xu" },
            { text = "心圩", comment = "xin xu" },
            { text = "新墟", comment = "xin xu" },
        },
        ["xin yu"] = {
            { text = "信誉", comment = "xin yu" },
            { text = "新余", comment = "xin yu" },
            { text = "新宇", comment = "xin yu" },
            { text = "心语", comment = "xin yu" },
            { text = "心雨", comment = "xin yu" },
            { text = "鑫宇", comment = "xin yu" },
            { text = "欣雨", comment = "xin yu" },
            { text = "欣宇", comment = "xin yu" },
            { text = "新语", comment = "xin yu" },
            { text = "馨予", comment = "xin yu" },
            { text = "新雨", comment = "xin yu" },
            { text = "鑫雨", comment = "xin yu" },
            { text = "新寓", comment = "xin yu" },
            { text = "信宇", comment = "xin yu" },
            { text = "心宇", comment = "xin yu" },
            { text = "辛宇", comment = "xin yu" },
            { text = "新玉", comment = "xin yu" },
            { text = "昕宇", comment = "xin yu" },
            { text = "馨雨", comment = "xin yu" },
            { text = "新誉", comment = "xin yu" },
            { text = "新域", comment = "xin yu" },
            { text = "鑫玉", comment = "xin yu" },
            { text = "新裕", comment = "xin yu" },
            { text = "鑫钰", comment = "xin yu" },
            { text = "馨语", comment = "xin yu" },
            { text = "鑫裕", comment = "xin yu" },
            { text = "欣语", comment = "xin yu" },
            { text = "欣瑜", comment = "xin yu" },
            { text = "辛雨", comment = "xin yu" },
            { text = "新禹", comment = "xin yu" },
            { text = "馨宇", comment = "xin yu" },
            { text = "新羽", comment = "xin yu" },
            { text = "昕雨", comment = "xin yu" },
            { text = "欣玉", comment = "xin yu" },
            { text = "信裕", comment = "xin yu" },
            { text = "心羽", comment = "xin yu" },
            { text = "心瑜", comment = "xin yu" },
            { text = "欣钰", comment = "xin yu" },
            { text = "心遇", comment = "xin yu" },
            { text = "心玉", comment = "xin yu" },
            { text = "欣妤", comment = "xin yu" },
            { text = "欣羽", comment = "xin yu" },
            { text = "新煜", comment = "xin yu" },
            { text = "欣昱", comment = "xin yu" },
            { text = "薪宇", comment = "xin yu" },
        },
        ["xing a"] = {
            { text = "行啊", comment = "xing a" },
        },
        ["xing ai"] = {
            { text = "性爱", comment = "xing ai" },
        },
        ["xing an"] = {
            { text = "兴安", comment = "xing an" },
            { text = "刑案", comment = "xing an" },
            { text = "星安", comment = "xing an" },
        },
        ["xing ang"] = {
            { text = "兴昂", comment = "xing ang" },
        },
        ["xing ao"] = {
            { text = "兴奥", comment = "xing ao" },
            { text = "星奥", comment = "xing ao" },
        },
        ["xing bu"] = {
            { text = "行不", comment = "xing bu" },
            { text = "刑部", comment = "xing bu" },
        },
        ["xing bu tou"] = {
            { text = "邢捕头", comment = "xing bu tou" },
        },
        ["xing huai"] = {
            { text = "兴怀", comment = "xing huai" },
        },
        ["xing li e"] = {
            { text = "行李额", comment = "xing li e" },
        },
        ["xing lie"] = {
            { text = "行猎", comment = "xing lie" },
        },
        ["xing ri"] = {
            { text = "星日", comment = "xing ri" },
            { text = "兴日", comment = "xing ri" },
        },
        ["xing xu"] = {
            { text = "兴许", comment = "xing xu" },
            { text = "星旭", comment = "xing xu" },
        },
        ["xing ye"] = {
            { text = "兴业", comment = "xing ye" },
            { text = "星爷", comment = "xing ye" },
            { text = "星夜", comment = "xing ye" },
            { text = "星野", comment = "xing ye" },
            { text = "星叶", comment = "xing ye" },
            { text = "兴叶", comment = "xing ye" },
            { text = "醒爷", comment = "xing ye" },
            { text = "性也", comment = "xing ye" },
            { text = "星业", comment = "xing ye" },
            { text = "星烨", comment = "xing ye" },
            { text = "兴烨", comment = "xing ye" },
            { text = "兴爷", comment = "xing ye" },
        },
        ["xing ye jie"] = {
            { text = "兴业街", comment = "xing ye jie" },
        },
        ["xiong an"] = {
            { text = "雄安", comment = "xiong an" },
            { text = "凶案", comment = "xiong an" },
            { text = "熊安", comment = "xiong an" },
        },
        ["xiong bu"] = {
            { text = "胸部", comment = "xiong bu" },
            { text = "熊部", comment = "xiong bu" },
        },
        ["xiong e"] = {
            { text = "凶恶", comment = "xiong e" },
        },
        ["xiong wo"] = {
            { text = "凶我", comment = "xiong wo" },
        },
        ["xiong xu"] = {
            { text = "熊旭", comment = "xiong xu" },
        },
        ["xiong ye"] = {
            { text = "雄业", comment = "xiong ye" },
            { text = "熊野", comment = "xiong ye" },
            { text = "雄爷", comment = "xiong ye" },
        },
        ["xiu a"] = {
            { text = "修啊", comment = "xiu a" },
            { text = "秀啊", comment = "xiu a" },
        },
        ["xiu ai"] = {
            { text = "秀爱", comment = "xiu ai" },
        },
        ["xiu an"] = {
            { text = "秀安", comment = "xiu an" },
        },
        ["xiu an lu"] = {
            { text = "秀安路", comment = "xiu an lu" },
        },
        ["xiu ao"] = {
            { text = "修奥", comment = "xiu ao" },
        },
        ["xiu di"] = {
            { text = "修帝", comment = "xiu di" },
            { text = "秀娣", comment = "xiu di" },
        },
        ["xiu di tie"] = {
            { text = "修地铁", comment = "xiu di tie" },
        },
        ["xiu ding ye"] = {
            { text = "修订页", comment = "xiu ding ye" },
        },
        ["xiu en"] = {
            { text = "秀恩", comment = "xiu en" },
        },
        ["xiu fo"] = {
            { text = "修佛", comment = "xiu fo" },
        },
        ["xu bu"] = {
            { text = "虚部", comment = "xu bu" },
            { text = "需补", comment = "xu bu" },
            { text = "徐部", comment = "xu bu" },
            { text = "许部", comment = "xu bu" },
            { text = "徐步", comment = "xu bu" },
        },
        ["xu da"] = {
            { text = "徐达", comment = "xu da" },
            { text = "旭达", comment = "xu da" },
            { text = "徐大", comment = "xu da" },
            { text = "许大", comment = "xu da" },
            { text = "许达", comment = "xu da" },
        },
        ["xu dai"] = {
            { text = "续贷", comment = "xu dai" },
            { text = "需带", comment = "xu dai" },
            { text = "糈傣", comment = "xu dai" },
        },
        ["xu dan"] = {
            { text = "徐丹", comment = "xu dan" },
            { text = "续单", comment = "xu dan" },
            { text = "许丹", comment = "xu dan" },
            { text = "虚单", comment = "xu dan" },
            { text = "旭丹", comment = "xu dan" },
        },
        ["xu dao"] = {
            { text = "絮叨", comment = "xu dao" },
            { text = "需到", comment = "xu dao" },
            { text = "续到", comment = "xu dao" },
            { text = "徐导", comment = "xu dao" },
            { text = "许导", comment = "xu dao" },
        },
        ["xu de"] = {
            { text = "虚的", comment = "xu de" },
            { text = "续的", comment = "xu de" },
            { text = "徐德", comment = "xu de" },
            { text = "许德", comment = "xu de" },
            { text = "旭德", comment = "xu de" },
        },
        ["xu duan"] = {
            { text = "续断", comment = "xu duan" },
            { text = "徐端", comment = "xu duan" },
        },
        ["xu duo"] = {
            { text = "许多", comment = "xu duo" },
        },
        ["xu er"] = {
            { text = "絮儿", comment = "xu er" },
            { text = "旭儿", comment = "xu er" },
        },
        ["xu huai"] = {
            { text = "虚淮", comment = "xu huai" },
        },
        ["xu nan"] = {
            { text = "徐楠", comment = "xu nan" },
            { text = "许楠", comment = "xu nan" },
            { text = "徐南", comment = "xu nan" },
        },
        ["xu ni e"] = {
            { text = "虚拟额", comment = "xu ni e" },
        },
        ["xu niu"] = {
            { text = "徐牛", comment = "xu niu" },
        },
        ["xu nuan"] = {
            { text = "煦暖", comment = "xu nuan" },
        },
        ["xu nuo"] = {
            { text = "许诺", comment = "xu nuo" },
            { text = "徐诺", comment = "xu nuo" },
            { text = "旭诺", comment = "xu nuo" },
        },
        ["xu ou"] = {
            { text = "序偶", comment = "xu ou" },
            { text = "旭欧", comment = "xu ou" },
        },
        ["xu ri"] = {
            { text = "旭日", comment = "xu ri" },
            { text = "圩日", comment = "xu ri" },
        },
        ["xu tan"] = {
            { text = "许坦", comment = "xu tan" },
            { text = "叙谈", comment = "xu tan" },
            { text = "徐坦", comment = "xu tan" },
            { text = "吁叹", comment = "xu tan" },
        },
        ["xu te"] = {
            { text = "徐特", comment = "xu te" },
        },
        ["xu tie"] = {
            { text = "徐铁", comment = "xu tie" },
        },
        ["xu tou"] = {
            { text = "虚头", comment = "xu tou" },
            { text = "续投", comment = "xu tou" },
        },
        ["xu tuan"] = {
            { text = "许疃", comment = "xu tuan" },
        },
        ["xu tuo"] = {
            { text = "虚脱", comment = "xu tuo" },
            { text = "旭拓", comment = "xu tuo" },
        },
        ["xuan huai"] = {
            { text = "宣怀", comment = "xuan huai" },
        },
        ["xuan ri"] = {
            { text = "轩日", comment = "xuan ri" },
        },
        ["xue a"] = {
            { text = "学啊", comment = "xue a" },
        },
        ["xue ai"] = {
            { text = "血癌", comment = "xue ai" },
            { text = "学癌", comment = "xue ai" },
        },
        ["xue an"] = {
            { text = "学案", comment = "xue an" },
            { text = "血案", comment = "xue an" },
            { text = "血氨", comment = "xue an" },
            { text = "学安", comment = "xue an" },
        },
        ["xue ao"] = {
            { text = "雪獒", comment = "xue ao" },
        },
        ["xue e"] = {
            { text = "雪娥", comment = "xue e" },
            { text = "学哦", comment = "xue e" },
        },
        ["xue fo"] = {
            { text = "学佛", comment = "xue fo" },
        },
        ["xue hua yin"] = {
            { text = "雪花银", comment = "xue hua yin" },
        },
        ["xue o"] = {
            { text = "学哦", comment = "xue o" },
        },
        ["xue ri yu"] = {
            { text = "学日语", comment = "xue ri yu" },
        },
        ["xue wo"] = {
            { text = "学我", comment = "xue wo" },
        },
        ["xue xu"] = {
            { text = "血虚", comment = "xue xu" },
        },
        ["xun an"] = {
            { text = "巡按", comment = "xun an" },
        },
        ["xun bu"] = {
            { text = "巡捕", comment = "xun bu" },
            { text = "迅步", comment = "xun bu" },
        },
        ["xun huai"] = {
            { text = "循坏", comment = "xun huai" },
        },
        ["xun ou"] = {
            { text = "讯欧", comment = "xun ou" },
        },
        ["xun ri"] = {
            { text = "寻日", comment = "xun ri" },
            { text = "旬日", comment = "xun ri" },
        },
        ["xun wo"] = {
            { text = "训我", comment = "xun wo" },
        },
        ["xun xu"] = {
            { text = "循序", comment = "xun xu" },
        },
        ["xun ye"] = {
            { text = "巡夜", comment = "xun ye" },
            { text = "勋业", comment = "xun ye" },
        },
        ["xun yu"] = {
            { text = "荀彧", comment = "xun yu" },
            { text = "鲟鱼", comment = "xun yu" },
            { text = "熏鱼", comment = "xun yu" },
            { text = "荤粥", comment = "xun yu" },
            { text = "迅羽", comment = "xun yu" },
            { text = "训育", comment = "xun yu" },
            { text = "训谕", comment = "xun yu" },
            { text = "獯鬻", comment = "xun yu" },
            { text = "训喻", comment = "xun yu" },
        },
        ["ya ba"] = {
            { text = "哑巴", comment = "ya ba" },
            { text = "牙巴", comment = "ya ba" },
            { text = "丫霸", comment = "ya ba" },
        },
        ["ya bai"] = {
            { text = "牙白", comment = "ya bai" },
            { text = "哑白", comment = "ya bai" },
            { text = "崖柏", comment = "ya bai" },
            { text = "雅白", comment = "ya bai" },
            { text = "芽白", comment = "ya bai" },
            { text = "亚白", comment = "ya bai" },
            { text = "哑柏", comment = "ya bai" },
            { text = "雅柏", comment = "ya bai" },
        },
        ["ya ban"] = {
            { text = "压板", comment = "ya ban" },
            { text = "牙板", comment = "ya ban" },
        },
        ["ya bao"] = {
            { text = "亚宝", comment = "ya bao" },
            { text = "雅宝", comment = "ya bao" },
            { text = "芽孢", comment = "ya bao" },
            { text = "押宝", comment = "ya bao" },
            { text = "压包", comment = "ya bao" },
            { text = "牙包", comment = "ya bao" },
            { text = "鸭煲", comment = "ya bao" },
            { text = "压堡", comment = "ya bao" },
            { text = "压宝", comment = "ya bao" },
        },
        ["ya bei"] = {
            { text = "牙杯", comment = "ya bei" },
            { text = "亚北", comment = "ya bei" },
            { text = "雅贝", comment = "ya bei" },
        },
        ["ya ben"] = {
            { text = "雅本", comment = "ya ben" },
        },
        ["ya bin"] = {
            { text = "亚斌", comment = "ya bin" },
            { text = "亚彬", comment = "ya bin" },
            { text = "雅彬", comment = "ya bin" },
            { text = "亚宾", comment = "ya bin" },
        },
        ["ya bo"] = {
            { text = "鸭脖", comment = "ya bo" },
            { text = "亚博", comment = "ya bo" },
            { text = "雅博", comment = "ya bo" },
            { text = "亚波", comment = "ya bo" },
            { text = "亚伯", comment = "ya bo" },
        },
        ["ya bu"] = {
            { text = "亚布", comment = "ya bu" },
            { text = "雅布", comment = "ya bu" },
            { text = "压堡", comment = "ya bu" },
        },
        ["ya nan"] = {
            { text = "亚楠", comment = "ya nan" },
            { text = "亚男", comment = "ya nan" },
            { text = "雅楠", comment = "ya nan" },
            { text = "亚南", comment = "ya nan" },
            { text = "娅楠", comment = "ya nan" },
            { text = "雅男", comment = "ya nan" },
            { text = "雅南", comment = "ya nan" },
            { text = "娅男", comment = "ya nan" },
            { text = "亚囡", comment = "ya nan" },
        },
        ["ya nei"] = {
            { text = "衙内", comment = "ya nei" },
        },
        ["ya niu"] = {
            { text = "亚牛", comment = "ya niu" },
        },
        ["ya nuan"] = {
            { text = "鸭暖", comment = "ya nuan" },
        },
        ["ya nuo"] = {
            { text = "雅诺", comment = "ya nuo" },
            { text = "亚诺", comment = "ya nuo" },
        },
        ["ya ou"] = {
            { text = "亚欧", comment = "ya ou" },
        },
        ["ya ta"] = {
            { text = "压他", comment = "ya ta" },
            { text = "压塌", comment = "ya ta" },
        },
        ["ya tai"] = {
            { text = "亚太", comment = "ya tai" },
            { text = "亚泰", comment = "ya tai" },
            { text = "雅泰", comment = "ya tai" },
            { text = "压台", comment = "ya tai" },
        },
        ["ya tan"] = {
            { text = "鸦滩", comment = "ya tan" },
        },
        ["ya tao"] = {
            { text = "牙套", comment = "ya tao" },
            { text = "亚涛", comment = "ya tao" },
            { text = "雅涛", comment = "ya tao" },
        },
        ["ya tie"] = {
            { text = "亚铁", comment = "ya tie" },
            { text = "牙贴", comment = "ya tie" },
            { text = "压贴", comment = "ya tie" },
        },
        ["ya tou"] = {
            { text = "丫头", comment = "ya tou" },
            { text = "鸭头", comment = "ya tou" },
            { text = "压头", comment = "ya tou" },
            { text = "崖头", comment = "ya tou" },
            { text = "芽头", comment = "ya tou" },
            { text = "牙头", comment = "ya tou" },
            { text = "押头", comment = "ya tou" },
            { text = "吖头", comment = "ya tou" },
            { text = "鸦头", comment = "ya tou" },
        },
        ["ya tuo"] = {
            { text = "牙托", comment = "ya tuo" },
            { text = "亚拓", comment = "ya tuo" },
        },
        ["yan an"] = {
            { text = "延安", comment = "yan an" },
            { text = "沿岸", comment = "yan an" },
            { text = "闫安", comment = "yan an" },
        },
        ["yan bu"] = {
            { text = "眼部", comment = "yan bu" },
            { text = "咽部", comment = "yan bu" },
            { text = "盐步", comment = "yan bu" },
            { text = "验布", comment = "yan bu" },
            { text = "闫部", comment = "yan bu" },
        },
        ["yan di"] = {
            { text = "眼底", comment = "yan di" },
            { text = "炎帝", comment = "yan di" },
            { text = "烟蒂", comment = "yan di" },
            { text = "严迪", comment = "yan di" },
            { text = "闫迪", comment = "yan di" },
            { text = "砚滴", comment = "yan di" },
        },
        ["yan ou"] = {
            { text = "燕鸥", comment = "yan ou" },
        },
        ["yan wo"] = {
            { text = "燕窝", comment = "yan wo" },
            { text = "演我", comment = "yan wo" },
            { text = "眼窝", comment = "yan wo" },
            { text = "盐窝", comment = "yan wo" },
        },
        ["yan xu"] = {
            { text = "延续", comment = "yan xu" },
            { text = "闫旭", comment = "yan xu" },
            { text = "严旭", comment = "yan xu" },
            { text = "颜旭", comment = "yan xu" },
            { text = "延旭", comment = "yan xu" },
        },
        ["yan yu"] = {
            { text = "言语", comment = "yan yu" },
            { text = "烟雨", comment = "yan yu" },
            { text = "谚语", comment = "yan yu" },
            { text = "艳遇", comment = "yan yu" },
            { text = "言喻", comment = "yan yu" },
            { text = "宴遇", comment = "yan yu" },
            { text = "严宇", comment = "yan yu" },
            { text = "腌鱼", comment = "yan yu" },
            { text = "闫宇", comment = "yan yu" },
            { text = "燕鱼", comment = "yan yu" },
            { text = "盐浴", comment = "yan yu" },
            { text = "颜宇", comment = "yan yu" },
            { text = "彦宇", comment = "yan yu" },
            { text = "燕宇", comment = "yan yu" },
            { text = "燕玉", comment = "yan yu" },
            { text = "燕语", comment = "yan yu" },
            { text = "闫玉", comment = "yan yu" },
            { text = "严羽", comment = "yan yu" },
            { text = "闫雨", comment = "yan yu" },
            { text = "艳玉", comment = "yan yu" },
            { text = "颜玉", comment = "yan yu" },
            { text = "燕瑜", comment = "yan yu" },
            { text = "艳宇", comment = "yan yu" },
        },
        ["yang a"] = {
            { text = "样啊", comment = "yang a" },
            { text = "阳阿", comment = "yang a" },
        },
        ["yang ai"] = {
            { text = "杨爱", comment = "yang ai" },
        },
        ["yang an"] = {
            { text = "杨安", comment = "yang an" },
            { text = "羊安", comment = "yang an" },
            { text = "阳安", comment = "yang an" },
            { text = "杨桉", comment = "yang an" },
        },
        ["yang ao"] = {
            { text = "杨傲", comment = "yang ao" },
            { text = "杨奥", comment = "yang ao" },
        },
        ["yang bu"] = {
            { text = "样布", comment = "yang bu" },
            { text = "杨部", comment = "yang bu" },
            { text = "杨埠", comment = "yang bu" },
            { text = "洋布", comment = "yang bu" },
        },
        ["yang huai"] = {
            { text = "洋槐", comment = "yang huai" },
            { text = "杨怀", comment = "yang huai" },
            { text = "杨槐", comment = "yang huai" },
        },
        ["yang ou"] = {
            { text = "杨欧", comment = "yang ou" },
        },
        ["yang ri"] = {
            { text = "阳日", comment = "yang ri" },
        },
        ["yang wo"] = {
            { text = "养我", comment = "yang wo" },
            { text = "仰卧", comment = "yang wo" },
        },
        ["yang ye"] = {
            { text = "杨业", comment = "yang ye" },
            { text = "杨烨", comment = "yang ye" },
            { text = "杨叶", comment = "yang ye" },
            { text = "杨晔", comment = "yang ye" },
            { text = "杨野", comment = "yang ye" },
        },
        ["yao a"] = {
            { text = "要啊", comment = "yao a" },
        },
        ["yao ai"] = {
            { text = "要爱", comment = "yao ai" },
            { text = "要隘", comment = "yao ai" },
        },
        ["yao an"] = {
            { text = "要按", comment = "yao an" },
            { text = "姚安", comment = "yao an" },
            { text = "要案", comment = "yao an" },
            { text = "耀安", comment = "yao an" },
            { text = "瑶安", comment = "yao an" },
        },
        ["yao ao"] = {
            { text = "要熬", comment = "yao ao" },
        },
        ["yao di"] = {
            { text = "姚笛", comment = "yao di" },
            { text = "要低", comment = "yao di" },
            { text = "要地", comment = "yao di" },
            { text = "腰骶", comment = "yao di" },
            { text = "幺弟", comment = "yao di" },
            { text = "妖帝", comment = "yao di" },
            { text = "尧帝", comment = "yao di" },
        },
        ["yao en"] = {
            { text = "姚恩", comment = "yao en" },
        },
        ["yao huai"] = {
            { text = "要坏", comment = "yao huai" },
            { text = "咬坏", comment = "yao huai" },
        },
        ["yao o"] = {
            { text = "要哦", comment = "yao o" },
        },
        ["yao ri"] = {
            { text = "曜日", comment = "yao ri" },
        },
        ["yao yu"] = {
            { text = "要与", comment = "yao yu" },
            { text = "药浴", comment = "yao yu" },
            { text = "瑶浴", comment = "yao yu" },
            { text = "姚宇", comment = "yao yu" },
            { text = "鳐鱼", comment = "yao yu" },
            { text = "耀宇", comment = "yao yu" },
            { text = "姚玉", comment = "yao yu" },
            { text = "姚雨", comment = "yao yu" },
            { text = "瑶玉", comment = "yao yu" },
            { text = "姚煜", comment = "yao yu" },
            { text = "姚瑜", comment = "yao yu" },
        },
        ["ye bu"] = {
            { text = "也不", comment = "ye bu" },
            { text = "叶部", comment = "ye bu" },
            { text = "夜不", comment = "ye bu" },
        },
        ["ye huai"] = {
            { text = "也坏", comment = "ye huai" },
        },
        ["ye ou"] = {
            { text = "业欧", comment = "ye ou" },
            { text = "液偶", comment = "ye ou" },
        },
        ["ye ri"] = {
            { text = "野日", comment = "ye ri" },
        },
        ["yi bu"] = {
            { text = "一步", comment = "yi bu" },
            { text = "一部", comment = "yi bu" },
            { text = "异步", comment = "yi bu" },
            { text = "已补", comment = "yi bu" },
            { text = "移步", comment = "yi bu" },
            { text = "伊布", comment = "yi bu" },
            { text = "一补", comment = "yi bu" },
            { text = "一不", comment = "yi bu" },
            { text = "以不", comment = "yi bu" },
            { text = "已不", comment = "yi bu" },
            { text = "一布", comment = "yi bu" },
            { text = "亦不", comment = "yi bu" },
            { text = "乙部", comment = "yi bu" },
        },
        ["yi di tou"] = {
            { text = "一低头", comment = "yi di tou" },
        },
        ["yi ding bu"] = {
            { text = "一定不", comment = "yi ding bu" },
        },
        ["yi huai"] = {
            { text = "已坏", comment = "yi huai" },
        },
        ["yi ji dan"] = {
            { text = "移机单", comment = "yi ji dan" },
        },
        ["yi jie an"] = {
            { text = "已结案", comment = "yi jie an" },
        },
        ["yi nai"] = {
            { text = "姨奶", comment = "yi nai" },
            { text = "溢奶", comment = "yi nai" },
            { text = "一耐", comment = "yi nai" },
        },
        ["yi nan"] = {
            { text = "一男", comment = "yi nan" },
            { text = "疑难", comment = "yi nan" },
            { text = "以南", comment = "yi nan" },
            { text = "沂南", comment = "yi nan" },
            { text = "一楠", comment = "yi nan" },
            { text = "轶男", comment = "yi nan" },
            { text = "伊楠", comment = "yi nan" },
            { text = "亦男", comment = "yi nan" },
        },
        ["yi nei"] = {
            { text = "以内", comment = "yi nei" },
        },
        ["yi nie"] = {
            { text = "一捏", comment = "yi nie" },
        },
        ["yi niu"] = {
            { text = "一扭", comment = "yi niu" },
            { text = "一牛", comment = "yi niu" },
        },
        ["yi nuan"] = {
            { text = "一暖", comment = "yi nuan" },
        },
        ["yi nue"] = {
            { text = "一虐", comment = "yi nue" },
            { text = "以虐", comment = "yi nue" },
        },
        ["yi nuo"] = {
            { text = "一诺", comment = "yi nuo" },
            { text = "依诺", comment = "yi nuo" },
            { text = "伊诺", comment = "yi nuo" },
            { text = "以诺", comment = "yi nuo" },
            { text = "亿诺", comment = "yi nuo" },
            { text = "壹诺", comment = "yi nuo" },
            { text = "艺诺", comment = "yi nuo" },
            { text = "怡诺", comment = "yi nuo" },
            { text = "医诺", comment = "yi nuo" },
        },
        ["yi ou"] = {
            { text = "亿欧", comment = "yi ou" },
            { text = "以偶", comment = "yi ou" },
            { text = "遗鸥", comment = "yi ou" },
            { text = "一欧", comment = "yi ou" },
        },
        ["yi ri"] = {
            { text = "一日", comment = "yi ri" },
            { text = "翌日", comment = "yi ri" },
            { text = "亿日", comment = "yi ri" },
            { text = "异日", comment = "yi ri" },
        },
        ["yi ta"] = {
            { text = "一塔", comment = "yi ta" },
            { text = "以他", comment = "yi ta" },
            { text = "以她", comment = "yi ta" },
            { text = "以它", comment = "yi ta" },
        },
        ["yi tai"] = {
            { text = "一台", comment = "yi tai" },
            { text = "一胎", comment = "yi tai" },
            { text = "以太", comment = "yi tai" },
            { text = "仪态", comment = "yi tai" },
            { text = "伊泰", comment = "yi tai" },
            { text = "一抬", comment = "yi tai" },
            { text = "亿泰", comment = "yi tai" },
            { text = "姨太", comment = "yi tai" },
            { text = "益泰", comment = "yi tai" },
            { text = "易泰", comment = "yi tai" },
            { text = "以钛", comment = "yi tai" },
            { text = "怡泰", comment = "yi tai" },
            { text = "一太", comment = "yi tai" },
            { text = "易太", comment = "yi tai" },
            { text = "溢泰", comment = "yi tai" },
            { text = "乙太", comment = "yi tai" },
        },
        ["yi tan"] = {
            { text = "一谈", comment = "yi tan" },
            { text = "一滩", comment = "yi tan" },
            { text = "一摊", comment = "yi tan" },
            { text = "一坛", comment = "yi tan" },
            { text = "一探", comment = "yi tan" },
            { text = "一叹", comment = "yi tan" },
            { text = "一潭", comment = "yi tan" },
            { text = "易坛", comment = "yi tan" },
        },
        ["yi tao"] = {
            { text = "一套", comment = "yi tao" },
            { text = "一淘", comment = "yi tao" },
            { text = "椅套", comment = "yi tao" },
            { text = "易涛", comment = "yi tao" },
            { text = "逸淘", comment = "yi tao" },
            { text = "壹套", comment = "yi tao" },
            { text = "易淘", comment = "yi tao" },
            { text = "逸涛", comment = "yi tao" },
            { text = "艺涛", comment = "yi tao" },
            { text = "沂涛", comment = "yi tao" },
            { text = "义涛", comment = "yi tao" },
            { text = "一涛", comment = "yi tao" },
        },
        ["yi te"] = {
            { text = "伊特", comment = "yi te" },
            { text = "一特", comment = "yi te" },
            { text = "易特", comment = "yi te" },
            { text = "宜特", comment = "yi te" },
            { text = "亿特", comment = "yi te" },
            { text = "艺特", comment = "yi te" },
        },
        ["yi ti bu"] = {
            { text = "艺体部", comment = "yi ti bu" },
        },
        ["yi ti de"] = {
            { text = "一体的", comment = "yi ti de" },
        },
        ["yi tie"] = {
            { text = "一贴", comment = "yi tie" },
            { text = "已贴", comment = "yi tie" },
            { text = "一帖", comment = "yi tie" },
            { text = "异铁", comment = "yi tie" },
            { text = "亿铁", comment = "yi tie" },
        },
        ["yi tou"] = {
            { text = "一头", comment = "yi tou" },
            { text = "已投", comment = "yi tou" },
            { text = "一投", comment = "yi tou" },
            { text = "易投", comment = "yi tou" },
            { text = "医投", comment = "yi tou" },
        },
        ["yi tuan"] = {
            { text = "一团", comment = "yi tuan" },
            { text = "疑团", comment = "yi tuan" },
        },
        ["yi tuo"] = {
            { text = "依托", comment = "yi tuo" },
            { text = "一坨", comment = "yi tuo" },
            { text = "一拖", comment = "yi tuo" },
            { text = "一托", comment = "yi tuo" },
            { text = "一脱", comment = "yi tuo" },
            { text = "医托", comment = "yi tuo" },
            { text = "衣托", comment = "yi tuo" },
            { text = "易拓", comment = "yi tuo" },
        },
        ["yi xia o"] = {
            { text = "一下哦", comment = "yi xia o" },
        },
        ["yi xiao"] = {
            { text = "一笑", comment = "yi xiao" },
            { text = "一小", comment = "yi xiao" },
            { text = "艺校", comment = "yi xiao" },
            { text = "一校", comment = "yi xiao" },
            { text = "一消", comment = "yi xiao" },
            { text = "已销", comment = "yi xiao" },
            { text = "一肖", comment = "yi xiao" },
            { text = "以小", comment = "yi xiao" },
            { text = "益消", comment = "yi xiao" },
            { text = "议销", comment = "yi xiao" },
        },
        ["yin ai"] = {
            { text = "因爱", comment = "yin ai" },
        },
        ["yin an"] = {
            { text = "阴暗", comment = "yin an" },
            { text = "银安", comment = "yin an" },
        },
        ["yin bu"] = {
            { text = "印布", comment = "yin bu" },
            { text = "尹部", comment = "yin bu" },
            { text = "阴部", comment = "yin bu" },
        },
        ["yin di"] = {
            { text = "阴蒂", comment = "yin di" },
            { text = "银地", comment = "yin di" },
            { text = "因地", comment = "yin di" },
            { text = "银底", comment = "yin di" },
        },
        ["yin hua bu"] = {
            { text = "印花布", comment = "yin hua bu" },
        },
        ["yin ne"] = {
            { text = "银呢", comment = "yin ne" },
        },
        ["yin ou"] = {
            { text = "银鸥", comment = "yin ou" },
        },
        ["yin rou"] = {
            { text = "阴柔", comment = "yin rou" },
        },
        ["yin wo"] = {
            { text = "阴我", comment = "yin wo" },
            { text = "因我", comment = "yin wo" },
            { text = "淫窝", comment = "yin wo" },
        },
        ["yin xu"] = {
            { text = "阴虚", comment = "yin xu" },
            { text = "音序", comment = "yin xu" },
            { text = "殷墟", comment = "yin xu" },
            { text = "尹旭", comment = "yin xu" },
            { text = "殷旭", comment = "yin xu" },
            { text = "银旭", comment = "yin xu" },
        },
        ["yin ye"] = {
            { text = "夤夜", comment = "yin ye" },
            { text = "印业", comment = "yin ye" },
            { text = "淫液", comment = "yin ye" },
            { text = "银叶", comment = "yin ye" },
        },
        ["yin yu"] = {
            { text = "阴雨", comment = "yin yu" },
            { text = "隐喻", comment = "yin yu" },
            { text = "银鱼", comment = "yin yu" },
            { text = "阴郁", comment = "yin yu" },
            { text = "音域", comment = "yin yu" },
            { text = "引语", comment = "yin yu" },
            { text = "淫欲", comment = "yin yu" },
            { text = "淫雨", comment = "yin yu" },
            { text = "因与", comment = "yin yu" },
            { text = "尹玉", comment = "yin yu" },
            { text = "银宇", comment = "yin yu" },
            { text = "音遇", comment = "yin yu" },
            { text = "隐语", comment = "yin yu" },
            { text = "饮誉", comment = "yin yu" },
        },
        ["ying a"] = {
            { text = "赢啊", comment = "ying a" },
        },
        ["ying ai"] = {
            { text = "英爱", comment = "ying ai" },
            { text = "萤爱", comment = "ying ai" },
            { text = "硬爱", comment = "ying ai" },
            { text = "硬挨", comment = "ying ai" },
        },
        ["ying an"] = {
            { text = "应按", comment = "ying an" },
            { text = "盈安", comment = "ying an" },
        },
        ["ying ao"] = {
            { text = "英澳", comment = "ying ao" },
        },
        ["ying bu"] = {
            { text = "营部", comment = "ying bu" },
            { text = "应补", comment = "ying bu" },
            { text = "赢不", comment = "ying bu" },
            { text = "英布", comment = "ying bu" },
        },
        ["ying e"] = {
            { text = "硬腭", comment = "ying e" },
        },
        ["ying huai"] = {
            { text = "颍淮", comment = "ying huai" },
            { text = "萦怀", comment = "ying huai" },
        },
        ["ying ri"] = {
            { text = "映日", comment = "ying ri" },
        },
        ["ying wo"] = {
            { text = "硬卧", comment = "ying wo" },
            { text = "赢我", comment = "ying wo" },
            { text = "英沃", comment = "ying wo" },
        },
        ["ying xu"] = {
            { text = "应许", comment = "ying xu" },
            { text = "迎旭", comment = "ying xu" },
        },
        ["ying ye"] = {
            { text = "营业", comment = "ying ye" },
            { text = "影业", comment = "ying ye" },
        },
        ["ying ye e"] = {
            { text = "营业额", comment = "ying ye e" },
        },
        ["ying you"] = {
            { text = "应有", comment = "ying you" },
            { text = "应由", comment = "ying you" },
            { text = "婴幼", comment = "ying you" },
            { text = "影友", comment = "ying you" },
            { text = "营友", comment = "ying you" },
            { text = "鹰游", comment = "ying you" },
            { text = "营优", comment = "ying you" },
        },
        ["yo wei"] = {
            { text = "哟喂", comment = "yo wei" },
        },
        ["yong huai"] = {
            { text = "用坏", comment = "yong huai" },
            { text = "咏怀", comment = "yong huai" },
        },
        ["yong ri"] = {
            { text = "永日", comment = "yong ri" },
        },
        ["you di"] = {
            { text = "有地", comment = "you di" },
            { text = "有底", comment = "you di" },
            { text = "有滴", comment = "you di" },
            { text = "邮递", comment = "you di" },
            { text = "又低", comment = "you di" },
            { text = "油滴", comment = "you di" },
            { text = "诱敌", comment = "you di" },
            { text = "优迪", comment = "you di" },
        },
        ["you ei"] = {
            { text = "有诶", comment = "you ei" },
        },
        ["you hua bu"] = {
            { text = "油画布", comment = "you hua bu" },
            { text = "优化部", comment = "you hua bu" },
        },
        ["you huai"] = {
            { text = "右踝", comment = "you huai" },
            { text = "有坏", comment = "you huai" },
            { text = "又坏", comment = "you huai" },
        },
        ["you ji tan"] = {
            { text = "有机碳", comment = "you ji tan" },
        },
        ["you jing an"] = {
            { text = "尤靖安", comment = "you jing an" },
        },
        ["you me you"] = {
            { text = "有么有", comment = "you me you" },
        },
        ["you mei ou"] = {
            { text = "又没偶", comment = "you mei ou" },
        },
        ["you ri"] = {
            { text = "有日", comment = "you ri" },
        },
        ["you rou"] = {
            { text = "有肉", comment = "you rou" },
            { text = "优柔", comment = "you rou" },
        },
        ["you xi duan"] = {
            { text = "游戏端", comment = "you xi duan" },
        },
        ["you xie xu"] = {
            { text = "有些许", comment = "you xie xu" },
        },
        ["yu ao"] = {
            { text = "于鏊", comment = "yu ao" },
            { text = "宇傲", comment = "yu ao" },
            { text = "宇奥", comment = "yu ao" },
        },
        ["yu bu"] = {
            { text = "雨布", comment = "yu bu" },
            { text = "余部", comment = "yu bu" },
            { text = "预补", comment = "yu bu" },
            { text = "于部", comment = "yu bu" },
            { text = "宇部", comment = "yu bu" },
            { text = "预卜", comment = "yu bu" },
            { text = "与不", comment = "yu bu" },
        },
        ["yu dai"] = {
            { text = "玉带", comment = "yu dai" },
            { text = "雨带", comment = "yu dai" },
            { text = "浴袋", comment = "yu dai" },
            { text = "玉带", comment = "yu dai" },
            { text = "雨带", comment = "yu dai" },
            { text = "浴袋", comment = "yu dai" },
        },
        ["yu dan"] = {
            { text = "于丹", comment = "yu dan" },
            { text = "鱼蛋", comment = "yu dan" },
            { text = "余丹", comment = "yu dan" },
            { text = "玉丹", comment = "yu dan" },
            { text = "余单", comment = "yu dan" },
            { text = "喻丹", comment = "yu dan" },
            { text = "俞丹", comment = "yu dan" },
            { text = "宇丹", comment = "yu dan" },
            { text = "于丹", comment = "yu dan" },
            { text = "鱼蛋", comment = "yu dan" },
            { text = "余丹", comment = "yu dan" },
            { text = "玉丹", comment = "yu dan" },
            { text = "余单", comment = "yu dan" },
            { text = "喻丹", comment = "yu dan" },
            { text = "俞丹", comment = "yu dan" },
            { text = "宇丹", comment = "yu dan" },
        },
        ["yu dao"] = {
            { text = "遇到", comment = "yu dao" },
            { text = "渔岛", comment = "yu dao" },
            { text = "御道", comment = "yu dao" },
            { text = "鱼道", comment = "yu dao" },
            { text = "遇到", comment = "yu dao" },
            { text = "渔岛", comment = "yu dao" },
            { text = "御道", comment = "yu dao" },
            { text = "鱼道", comment = "yu dao" },
        },
        ["yu de"] = {
            { text = "育德", comment = "yu de" },
            { text = "鱼的", comment = "yu de" },
            { text = "裕德", comment = "yu de" },
            { text = "雨的", comment = "yu de" },
            { text = "玉德", comment = "yu de" },
            { text = "誉德", comment = "yu de" },
            { text = "于德", comment = "yu de" },
            { text = "宇德", comment = "yu de" },
            { text = "余德", comment = "yu de" },
            { text = "育德", comment = "yu de" },
            { text = "鱼的", comment = "yu de" },
            { text = "裕德", comment = "yu de" },
            { text = "雨的", comment = "yu de" },
            { text = "玉德", comment = "yu de" },
            { text = "誉德", comment = "yu de" },
            { text = "于德", comment = "yu de" },
            { text = "宇德", comment = "yu de" },
            { text = "余德", comment = "yu de" },
        },
        ["yu die"] = {
            { text = "雨蝶", comment = "yu die" },
            { text = "玉蝶", comment = "yu die" },
            { text = "雨蝶", comment = "yu die" },
            { text = "玉蝶", comment = "yu die" },
        },
        ["yu dou"] = {
            { text = "禹都", comment = "yu dou" },
            { text = "雨都", comment = "yu dou" },
            { text = "玉豆", comment = "yu dou" },
            { text = "玉斗", comment = "yu dou" },
            { text = "禹都", comment = "yu dou" },
            { text = "雨都", comment = "yu dou" },
            { text = "玉豆", comment = "yu dou" },
            { text = "玉斗", comment = "yu dou" },
        },
        ["yu duan"] = {
            { text = "语段", comment = "yu duan" },
            { text = "预断", comment = "yu duan" },
            { text = "羽缎", comment = "yu duan" },
            { text = "语段", comment = "yu duan" },
            { text = "预断", comment = "yu duan" },
            { text = "羽缎", comment = "yu duan" },
        },
        ["yu duo"] = {
            { text = "雨多", comment = "yu duo" },
            { text = "愈多", comment = "yu duo" },
            { text = "俞垛", comment = "yu duo" },
            { text = "雨朵", comment = "yu duo" },
            { text = "誉多", comment = "yu duo" },
            { text = "窳惰", comment = "yu duo" },
            { text = "雨多", comment = "yu duo" },
            { text = "愈多", comment = "yu duo" },
            { text = "俞垛", comment = "yu duo" },
            { text = "雨朵", comment = "yu duo" },
            { text = "誉多", comment = "yu duo" },
            { text = "窳惰", comment = "yu duo" },
        },
        ["yu e"] = {
            { text = "余额", comment = "yu e" },
            { text = "余额", comment = "yu e" },
        },
        ["yu e bao"] = {
            { text = "余额宝", comment = "yu e bao" },
            { text = "余额宝", comment = "yu e bao" },
        },
        ["yu e biao"] = {
            { text = "余额表", comment = "yu e biao" },
            { text = "余额表", comment = "yu e biao" },
        },
        ["yu e wei"] = {
            { text = "余额为", comment = "yu e wei" },
            { text = "余额为", comment = "yu e wei" },
        },
        ["yu fo"] = {
            { text = "玉佛", comment = "yu fo" },
            { text = "浴佛", comment = "yu fo" },
        },
        ["yu na"] = {
            { text = "于娜", comment = "yu na" },
            { text = "余娜", comment = "yu na" },
            { text = "玉娜", comment = "yu na" },
            { text = "与那", comment = "yu na" },
            { text = "于娜", comment = "yu na" },
            { text = "余娜", comment = "yu na" },
            { text = "玉娜", comment = "yu na" },
            { text = "与那", comment = "yu na" },
        },
        ["yu nan"] = {
            { text = "遇难", comment = "yu nan" },
            { text = "豫南", comment = "yu nan" },
            { text = "郁南", comment = "yu nan" },
            { text = "鱼腩", comment = "yu nan" },
            { text = "渝南", comment = "yu nan" },
            { text = "于楠", comment = "yu nan" },
            { text = "余男", comment = "yu nan" },
            { text = "雨楠", comment = "yu nan" },
            { text = "宇楠", comment = "yu nan" },
            { text = "玉楠", comment = "yu nan" },
            { text = "遇难", comment = "yu nan" },
            { text = "豫南", comment = "yu nan" },
            { text = "郁南", comment = "yu nan" },
            { text = "鱼腩", comment = "yu nan" },
            { text = "渝南", comment = "yu nan" },
            { text = "于楠", comment = "yu nan" },
            { text = "余男", comment = "yu nan" },
            { text = "雨楠", comment = "yu nan" },
            { text = "宇楠", comment = "yu nan" },
            { text = "玉楠", comment = "yu nan" },
        },
        ["yu nei"] = {
            { text = "域内", comment = "yu nei" },
            { text = "宇内", comment = "yu nei" },
            { text = "域内", comment = "yu nei" },
            { text = "宇内", comment = "yu nei" },
        },
        ["yu nie"] = {
            { text = "余孽", comment = "yu nie" },
            { text = "欲孽", comment = "yu nie" },
            { text = "余孽", comment = "yu nie" },
            { text = "欲孽", comment = "yu nie" },
        },
        ["yu nin"] = {
            { text = "与您", comment = "yu nin" },
        },
        ["yu ou"] = {
            { text = "渔鸥", comment = "yu ou" },
            { text = "与偶", comment = "yu ou" },
            { text = "渝欧", comment = "yu ou" },
        },
        ["yuan bu"] = {
            { text = "远不", comment = "yuan bu" },
            { text = "院部", comment = "yuan bu" },
            { text = "园部", comment = "yuan bu" },
            { text = "袁部", comment = "yuan bu" },
            { text = "缘簿", comment = "yuan bu" },
        },
        ["yuan ou"] = {
            { text = "怨偶", comment = "yuan ou" },
        },
        ["yue"] = {
            { text = "月", comment = "yue" },
            { text = "越", comment = "yue" },
            { text = "约", comment = "yue" },
            { text = "曰", comment = "yue" },
            { text = "悦", comment = "yue" },
            { text = "岳", comment = "yue" },
            { text = "跃", comment = "yue" },
            { text = "乐", comment = "yue" },
            { text = "阅", comment = "yue" },
            { text = "粤", comment = "yue" },
            { text = "玥", comment = "yue" },
            { text = "钺", comment = "yue" },
            { text = "樾", comment = "yue" },
            { text = "栎", comment = "yue" },
            { text = "钥", comment = "yue" },
            { text = "刖", comment = "yue" },
            { text = "哕", comment = "yue" },
            { text = "龠", comment = "yue" },
            { text = "瀹", comment = "yue" },
            { text = "籥", comment = "yue" },
            { text = "趯", comment = "yue" },
            { text = "爚", comment = "yue" },
            { text = "汋", comment = "yue" },
            { text = "彟", comment = "yue" },
            { text = "说", comment = "yue" },
            { text = "焆", comment = "yue" },
            { text = "𫐄", comment = "yue" },
            { text = "𬸚", comment = "yue" },
            { text = "月", comment = "yue" },
            { text = "越", comment = "yue" },
            { text = "约", comment = "yue" },
            { text = "曰", comment = "yue" },
            { text = "悦", comment = "yue" },
            { text = "岳", comment = "yue" },
            { text = "跃", comment = "yue" },
            { text = "乐", comment = "yue" },
            { text = "阅", comment = "yue" },
            { text = "粤", comment = "yue" },
            { text = "玥", comment = "yue" },
            { text = "钺", comment = "yue" },
            { text = "樾", comment = "yue" },
            { text = "栎", comment = "yue" },
            { text = "钥", comment = "yue" },
            { text = "刖", comment = "yue" },
            { text = "哕", comment = "yue" },
            { text = "龠", comment = "yue" },
            { text = "瀹", comment = "yue" },
            { text = "籥", comment = "yue" },
            { text = "趯", comment = "yue" },
            { text = "爚", comment = "yue" },
            { text = "汋", comment = "yue" },
            { text = "彟", comment = "yue" },
            { text = "说", comment = "yue" },
            { text = "焆", comment = "yue" },
            { text = "𫐄", comment = "yue" },
            { text = "𬸚", comment = "yue" },
        },
        ["yue ai"] = {
            { text = "越爱", comment = "yue ai" },
            { text = "约爱", comment = "yue ai" },
            { text = "月爱", comment = "yue ai" },
            { text = "越爱", comment = "yue ai" },
            { text = "约爱", comment = "yue ai" },
            { text = "月爱", comment = "yue ai" },
        },
        ["yue an"] = {
            { text = "粤安", comment = "yue an" },
            { text = "月暗", comment = "yue an" },
            { text = "月安", comment = "yue an" },
            { text = "粤安", comment = "yue an" },
            { text = "月暗", comment = "yue an" },
            { text = "月安", comment = "yue an" },
        },
        ["yue ao"] = {
            { text = "粤澳", comment = "yue ao" },
            { text = "粤澳", comment = "yue ao" },
        },
        ["yue bao"] = {
            { text = "月报", comment = "yue bao" },
            { text = "月保", comment = "yue bao" },
            { text = "月包", comment = "yue bao" },
            { text = "粤宝", comment = "yue bao" },
            { text = "悦宝", comment = "yue bao" },
            { text = "约堡", comment = "yue bao" },
            { text = "越堡", comment = "yue bao" },
            { text = "月报", comment = "yue bao" },
            { text = "月保", comment = "yue bao" },
            { text = "月包", comment = "yue bao" },
            { text = "粤宝", comment = "yue bao" },
            { text = "悦宝", comment = "yue bao" },
            { text = "约堡", comment = "yue bao" },
            { text = "越堡", comment = "yue bao" },
        },
        ["yue biao"] = {
            { text = "月表", comment = "yue biao" },
            { text = "月标", comment = "yue biao" },
            { text = "月表", comment = "yue biao" },
            { text = "月标", comment = "yue biao" },
        },
        ["yue bu"] = {
            { text = "越不", comment = "yue bu" },
            { text = "月布", comment = "yue bu" },
            { text = "约不", comment = "yue bu" },
            { text = "月步", comment = "yue bu" },
            { text = "越不", comment = "yue bu" },
            { text = "月布", comment = "yue bu" },
            { text = "约不", comment = "yue bu" },
            { text = "月步", comment = "yue bu" },
        },
        ["yue e"] = {
            { text = "月娥", comment = "yue e" },
            { text = "月娥", comment = "yue e" },
        },
        ["yue wei"] = {
            { text = "悦薇", comment = "yue wei" },
            { text = "约为", comment = "yue wei" },
            { text = "月尾", comment = "yue wei" },
            { text = "越位", comment = "yue wei" },
            { text = "岳伟", comment = "yue wei" },
            { text = "岳巍", comment = "yue wei" },
            { text = "阅微", comment = "yue wei" },
            { text = "月为", comment = "yue wei" },
            { text = "乐薇", comment = "yue wei" },
            { text = "跃伟", comment = "yue wei" },
            { text = "悦薇", comment = "yue wei" },
            { text = "约为", comment = "yue wei" },
            { text = "月尾", comment = "yue wei" },
            { text = "越位", comment = "yue wei" },
            { text = "岳伟", comment = "yue wei" },
            { text = "岳巍", comment = "yue wei" },
            { text = "阅微", comment = "yue wei" },
            { text = "月为", comment = "yue wei" },
            { text = "乐薇", comment = "yue wei" },
            { text = "跃伟", comment = "yue wei" },
        },
        ["yue wo"] = {
            { text = "约我", comment = "yue wo" },
            { text = "约我", comment = "yue wo" },
        },
        ["yue xu"] = {
            { text = "约需", comment = "yue xu" },
            { text = "月旭", comment = "yue xu" },
            { text = "约需", comment = "yue xu" },
            { text = "月旭", comment = "yue xu" },
        },
        ["yue ye"] = {
            { text = "越野", comment = "yue ye" },
            { text = "月夜", comment = "yue ye" },
            { text = "月野", comment = "yue ye" },
            { text = "岳野", comment = "yue ye" },
            { text = "悦也", comment = "yue ye" },
            { text = "越野", comment = "yue ye" },
            { text = "月夜", comment = "yue ye" },
            { text = "月野", comment = "yue ye" },
            { text = "岳野", comment = "yue ye" },
            { text = "悦也", comment = "yue ye" },
        },
        ["yun a"] = {
            { text = "晕啊", comment = "yun a" },
            { text = "晕啊", comment = "yun a" },
        },
        ["yun an"] = {
            { text = "云安", comment = "yun an" },
            { text = "运安", comment = "yun an" },
            { text = "云安", comment = "yun an" },
            { text = "运安", comment = "yun an" },
        },
        ["yun di"] = {
            { text = "运抵", comment = "yun di" },
            { text = "云邸", comment = "yun di" },
            { text = "云迪", comment = "yun di" },
            { text = "云堤", comment = "yun di" },
            { text = "云滴", comment = "yun di" },
            { text = "运抵", comment = "yun di" },
            { text = "云邸", comment = "yun di" },
            { text = "云迪", comment = "yun di" },
            { text = "云堤", comment = "yun di" },
            { text = "云滴", comment = "yun di" },
        },
        ["yun ye"] = {
            { text = "云野", comment = "yun ye" },
            { text = "运业", comment = "yun ye" },
            { text = "云烨", comment = "yun ye" },
            { text = "云野", comment = "yun ye" },
            { text = "运业", comment = "yun ye" },
            { text = "云烨", comment = "yun ye" },
        },
        ["yun yu"] = {
            { text = "孕育", comment = "yun yu" },
            { text = "云雨", comment = "yun yu" },
            { text = "云宇", comment = "yun yu" },
            { text = "韵语", comment = "yun yu" },
        },
        ["za ba"] = {
            { text = "砸吧", comment = "za ba" },
            { text = "咋把", comment = "za ba" },
        },
        ["za ban"] = {
            { text = "咋办", comment = "za ban" },
            { text = "杂办", comment = "za ban" },
            { text = "杂拌", comment = "za ban" },
            { text = "砸板", comment = "za ban" },
        },
        ["za ban a"] = {
            { text = "咋办啊", comment = "za ban a" },
        },
        ["za ban ya"] = {
            { text = "咋办呀", comment = "za ban ya" },
        },
        ["za bei"] = {
            { text = "砸碑", comment = "za bei" },
        },
        ["za bo"] = {
            { text = "杂波", comment = "za bo" },
        },
        ["za na"] = {
            { text = "咋拿", comment = "za na" },
        },
        ["za nan"] = {
            { text = "咋喃", comment = "za nan" },
        },
        ["za nei"] = {
            { text = "咋内", comment = "za nei" },
        },
        ["za nen"] = {
            { text = "咋嫩", comment = "za nen" },
        },
        ["za nie"] = {
            { text = "咋捏", comment = "za nie" },
        },
        ["za tie"] = {
            { text = "杂铁", comment = "za tie" },
        },
        ["za ya"] = {
            { text = "咋呀", comment = "za ya" },
        },
        ["za yan"] = {
            { text = "杂言", comment = "za yan" },
        },
        ["za yang"] = {
            { text = "咋样", comment = "za yang" },
            { text = "咋养", comment = "za yang" },
        },
        ["za yao"] = {
            { text = "咋要", comment = "za yao" },
        },
        ["za ye"] = {
            { text = "咋也", comment = "za ye" },
        },
        ["za yin"] = {
            { text = "杂音", comment = "za yin" },
        },
        ["za you"] = {
            { text = "咋又", comment = "za you" },
            { text = "咋有", comment = "za you" },
        },
        ["za yue"] = {
            { text = "匝月", comment = "za yue" },
        },
        ["za yun"] = {
            { text = "砸晕", comment = "za yun" },
        },
        ["zai a"] = {
            { text = "在啊", comment = "zai a" },
        },
        ["zai an"] = {
            { text = "再按", comment = "zai an" },
            { text = "在案", comment = "zai an" },
            { text = "在俺", comment = "zai an" },
        },
        ["zai ang"] = {
            { text = "在昂", comment = "zai ang" },
        },
        ["zai ao"] = {
            { text = "再熬", comment = "zai ao" },
        },
        ["zai bu"] = {
            { text = "在不", comment = "zai bu" },
            { text = "再不", comment = "zai bu" },
            { text = "再补", comment = "zai bu" },
            { text = "在补", comment = "zai bu" },
        },
        ["zai e"] = {
            { text = "灾厄", comment = "zai e" },
        },
        ["zai huai"] = {
            { text = "再坏", comment = "zai huai" },
            { text = "在怀", comment = "zai huai" },
        },
        ["zai ma tou"] = {
            { text = "在码头", comment = "zai ma tou" },
        },
        ["zai mang bu"] = {
            { text = "在忙不", comment = "zai mang bu" },
        },
        ["zai ne"] = {
            { text = "在呢", comment = "zai ne" },
        },
        ["zai nv"] = {
            { text = "仔女", comment = "zai nv" },
        },
        ["zai ri"] = {
            { text = "在日", comment = "zai ri" },
        },
        ["zai yu"] = {
            { text = "在于", comment = "zai yu" },
            { text = "在与", comment = "zai yu" },
            { text = "再与", comment = "zai yu" },
            { text = "再遇", comment = "zai yu" },
            { text = "载誉", comment = "zai yu" },
            { text = "载于", comment = "zai yu" },
            { text = "在於", comment = "zai yu" },
        },
        ["zan a"] = {
            { text = "赞啊", comment = "zan a" },
        },
        ["zan an"] = {
            { text = "暂按", comment = "zan an" },
        },
        ["zan di"] = {
            { text = "咱弟", comment = "zan di" },
            { text = "攒底", comment = "zan di" },
        },
        ["zan en"] = {
            { text = "赞恩", comment = "zan en" },
        },
        ["zan ye"] = {
            { text = "咱也", comment = "zan ye" },
        },
        ["zang ye"] = {
            { text = "葬爷", comment = "zang ye" },
        },
        ["zao a"] = {
            { text = "早啊", comment = "zao a" },
            { text = "早吖", comment = "zao a" },
        },
        ["zao an"] = {
            { text = "早安", comment = "zao an" },
        },
        ["zao an a"] = {
            { text = "早安啊", comment = "zao an a" },
        },
        ["zao an ya"] = {
            { text = "早安呀", comment = "zao an ya" },
        },
        ["zao di"] = {
            { text = "造地", comment = "zao di" },
            { text = "早滴", comment = "zao di" },
        },
        ["zao o"] = {
            { text = "早哦", comment = "zao o" },
        },
        ["ze bu"] = {
            { text = "则不", comment = "ze bu" },
        },
        ["ze ou"] = {
            { text = "择偶", comment = "ze ou" },
        },
        ["ze tai"] = {
            { text = "泽泰", comment = "ze tai" },
        },
        ["ze te"] = {
            { text = "泽特", comment = "ze te" },
        },
        ["ze tou"] = {
            { text = "泽头", comment = "ze tou" },
        },
        ["ze you"] = {
            { text = "择优", comment = "ze you" },
            { text = "则有", comment = "ze you" },
            { text = "则由", comment = "ze you" },
        },
        ["ze yuan"] = {
            { text = "泽园", comment = "ze yuan" },
            { text = "泽源", comment = "ze yuan" },
            { text = "泽元", comment = "ze yuan" },
            { text = "泽远", comment = "ze yuan" },
        },
        ["zei ou"] = {
            { text = "贼鸥", comment = "zei ou" },
            { text = "贼鸥", comment = "zei ou" },
        },
        ["zeng ai"] = {
            { text = "曾爱", comment = "zeng ai" },
        },
        ["zeng bu"] = {
            { text = "增补", comment = "zeng bu" },
            { text = "曾部", comment = "zeng bu" },
        },
        ["zeng e"] = {
            { text = "增额", comment = "zeng e" },
        },
        ["zeng ou"] = {
            { text = "曾鸥", comment = "zeng ou" },
        },
        ["zha ba"] = {
            { text = "眨巴", comment = "zha ba" },
            { text = "扎巴", comment = "zha ba" },
            { text = "闸把", comment = "zha ba" },
            { text = "扎把", comment = "zha ba" },
        },
        ["zha ban"] = {
            { text = "闸板", comment = "zha ban" },
            { text = "炸板", comment = "zha ban" },
        },
        ["zha bao"] = {
            { text = "渣包", comment = "zha bao" },
            { text = "炸包", comment = "zha bao" },
        },
        ["zha bei"] = {
            { text = "闸北", comment = "zha bei" },
        },
        ["zha bin"] = {
            { text = "查斌", comment = "zha bin" },
        },
        ["zha bo"] = {
            { text = "查波", comment = "zha bo" },
        },
        ["zha ta"] = {
            { text = "炸他", comment = "zha ta" },
            { text = "炸塔", comment = "zha ta" },
        },
        ["zha tai"] = {
            { text = "扎胎", comment = "zha tai" },
        },
        ["zha tang"] = {
            { text = "炸膛", comment = "zha tang" },
        },
        ["zha te"] = {
            { text = "扎特", comment = "zha te" },
        },
        ["zha tie"] = {
            { text = "扎铁", comment = "zha tie" },
            { text = "渣铁", comment = "zha tie" },
        },
        ["zha tou"] = {
            { text = "扎头", comment = "zha tou" },
        },
        ["zha tuan"] = {
            { text = "炸团", comment = "zha tuan" },
        },
        ["zhan bu"] = {
            { text = "占卜", comment = "zhan bu" },
            { text = "展布", comment = "zhan bu" },
            { text = "搌布", comment = "zhan bu" },
        },
        ["zhan ou"] = {
            { text = "詹欧", comment = "zhan ou" },
        },
        ["zhang a"] = {
            { text = "账啊", comment = "zhang a" },
            { text = "长啊", comment = "zhang a" },
        },
        ["zhang ai"] = {
            { text = "障碍", comment = "zhang ai" },
            { text = "张爱", comment = "zhang ai" },
            { text = "张艾", comment = "zhang ai" },
        },
        ["zhang ang"] = {
            { text = "张昂", comment = "zhang ang" },
        },
        ["zhang bu"] = {
            { text = "张部", comment = "zhang bu" },
            { text = "长不", comment = "zhang bu" },
        },
        ["zhang e"] = {
            { text = "张娥", comment = "zhang e" },
        },
        ["zhang hu o"] = {
            { text = "账户哦", comment = "zhang hu o" },
        },
        ["zhang huai"] = {
            { text = "张怀", comment = "zhang huai" },
        },
        ["zhang huo"] = {
            { text = "掌火", comment = "zhang huo" },
        },
        ["zhang ou"] = {
            { text = "张鸥", comment = "zhang ou" },
            { text = "张欧", comment = "zhang ou" },
        },
        ["zhang ri"] = {
            { text = "张日", comment = "zhang ri" },
        },
        ["zhang xu"] = {
            { text = "张旭", comment = "zhang xu" },
            { text = "张徐", comment = "zhang xu" },
            { text = "张栩", comment = "zhang xu" },
            { text = "张绪", comment = "zhang xu" },
            { text = "张煦", comment = "zhang xu" },
            { text = "张许", comment = "zhang xu" },
            { text = "张续", comment = "zhang xu" },
            { text = "仗诩", comment = "zhang xu" },
            { text = "长旭", comment = "zhang xu" },
        },
        ["zhang ye"] = {
            { text = "张掖", comment = "zhang ye" },
            { text = "张烨", comment = "zhang ye" },
            { text = "账页", comment = "zhang ye" },
            { text = "张叶", comment = "zhang ye" },
            { text = "张也", comment = "zhang ye" },
            { text = "张野", comment = "zhang ye" },
            { text = "张晔", comment = "zhang ye" },
            { text = "张业", comment = "zhang ye" },
            { text = "张冶", comment = "zhang ye" },
            { text = "长冶", comment = "zhang ye" },
        },
        ["zhang yu de"] = {
            { text = "张玉德", comment = "zhang yu de" },
            { text = "张玉德", comment = "zhang yu de" },
        },
        ["zhang yue e"] = {
            { text = "张月娥", comment = "zhang yue e" },
            { text = "张月娥", comment = "zhang yue e" },
        },
        ["zhao a"] = {
            { text = "找啊", comment = "zhao a" },
        },
        ["zhao an"] = {
            { text = "诏安", comment = "zhao an" },
            { text = "招安", comment = "zhao an" },
            { text = "赵安", comment = "zhao an" },
            { text = "兆安", comment = "zhao an" },
            { text = "找俺", comment = "zhao an" },
        },
        ["zhao ao"] = {
            { text = "赵傲", comment = "zhao ao" },
        },
        ["zhao bu"] = {
            { text = "找不", comment = "zhao bu" },
            { text = "找补", comment = "zhao bu" },
            { text = "赵部", comment = "zhao bu" },
            { text = "照不", comment = "zhao bu" },
        },
        ["zhao di"] = {
            { text = "着地", comment = "zhao di" },
            { text = "找地", comment = "zhao di" },
            { text = "赵迪", comment = "zhao di" },
            { text = "招娣", comment = "zhao di" },
            { text = "招弟", comment = "zhao di" },
            { text = "赵娣", comment = "zhao di" },
            { text = "赵地", comment = "zhao di" },
            { text = "赵堤", comment = "zhao di" },
            { text = "招堤", comment = "zhao di" },
        },
        ["zhao o"] = {
            { text = "找哦", comment = "zhao o" },
        },
        ["zhao ou"] = {
            { text = "兆欧", comment = "zhao ou" },
        },
        ["zhao yu"] = {
            { text = "赵宇", comment = "zhao yu" },
            { text = "赵玉", comment = "zhao yu" },
            { text = "赵雨", comment = "zhao yu" },
            { text = "赵瑜", comment = "zhao yu" },
            { text = "赵钰", comment = "zhao yu" },
            { text = "赵煜", comment = "zhao yu" },
            { text = "兆宇", comment = "zhao yu" },
            { text = "赵禹", comment = "zhao yu" },
            { text = "赵昱", comment = "zhao yu" },
            { text = "赵羽", comment = "zhao yu" },
            { text = "昭宇", comment = "zhao yu" },
            { text = "赵渝", comment = "zhao yu" },
            { text = "朝宇", comment = "zhao yu" },
            { text = "照宇", comment = "zhao yu" },
        },
        ["zhe bu"] = {
            { text = "这不", comment = "zhe bu" },
            { text = "这部", comment = "zhe bu" },
            { text = "这步", comment = "zhe bu" },
        },
        ["zhe nan"] = {
            { text = "浙南", comment = "zhe nan" },
        },
        ["zhe nin"] = {
            { text = "这您", comment = "zhe nin" },
        },
        ["zhe niu"] = {
            { text = "这妞", comment = "zhe niu" },
        },
        ["zhe ou"] = {
            { text = "这欧", comment = "zhe ou" },
        },
        ["zhe tai"] = {
            { text = "这台", comment = "zhe tai" },
            { text = "这太", comment = "zhe tai" },
            { text = "这胎", comment = "zhe tai" },
            { text = "浙泰", comment = "zhe tai" },
        },
        ["zhe tan"] = {
            { text = "这摊", comment = "zhe tan" },
        },
        ["zhe tao"] = {
            { text = "这套", comment = "zhe tao" },
        },
        ["zhe te"] = {
            { text = "这特", comment = "zhe te" },
        },
        ["zhe tie"] = {
            { text = "这贴", comment = "zhe tie" },
            { text = "这帖", comment = "zhe tie" },
        },
        ["zhe tou"] = {
            { text = "这头", comment = "zhe tou" },
            { text = "折头", comment = "zhe tou" },
        },
        ["zhe tuan"] = {
            { text = "这团", comment = "zhe tuan" },
        },
        ["zhe tuo"] = {
            { text = "这坨", comment = "zhe tuo" },
        },
        ["zhe ya tou"] = {
            { text = "这丫头", comment = "zhe ya tou" },
        },
        ["zhe yang bu"] = {
            { text = "遮阳布", comment = "zhe yang bu" },
        },
        ["zhen an"] = {
            { text = "镇安", comment = "zhen an" },
            { text = "振安", comment = "zhen an" },
        },
        ["zhen ao"] = {
            { text = "珍奥", comment = "zhen ao" },
            { text = "真奥", comment = "zhen ao" },
        },
        ["zhen fo"] = {
            { text = "真佛", comment = "zhen fo" },
        },
        ["zhen huai"] = {
            { text = "真坏", comment = "zhen huai" },
        },
        ["zhen ri"] = {
            { text = "镇日", comment = "zhen ri" },
        },
        ["zhen yu"] = {
            { text = "阵雨", comment = "zhen yu" },
            { text = "振宇", comment = "zhen yu" },
            { text = "震宇", comment = "zhen yu" },
            { text = "镇域", comment = "zhen yu" },
            { text = "镇宇", comment = "zhen yu" },
            { text = "振玉", comment = "zhen yu" },
            { text = "振羽", comment = "zhen yu" },
            { text = "振誉", comment = "zhen yu" },
            { text = "畛域", comment = "zhen yu" },
            { text = "真鱼", comment = "zhen yu" },
            { text = "真玉", comment = "zhen yu" },
            { text = "阵雨", comment = "zhen yu" },
            { text = "振宇", comment = "zhen yu" },
            { text = "震宇", comment = "zhen yu" },
            { text = "镇域", comment = "zhen yu" },
            { text = "镇宇", comment = "zhen yu" },
            { text = "振玉", comment = "zhen yu" },
            { text = "振羽", comment = "zhen yu" },
            { text = "振誉", comment = "zhen yu" },
            { text = "畛域", comment = "zhen yu" },
            { text = "真鱼", comment = "zhen yu" },
            { text = "真玉", comment = "zhen yu" },
        },
        ["zheng ai"] = {
            { text = "郑爱", comment = "zheng ai" },
            { text = "正爱", comment = "zheng ai" },
        },
        ["zheng an"] = {
            { text = "正安", comment = "zheng an" },
            { text = "整案", comment = "zheng an" },
            { text = "蒸氨", comment = "zheng an" },
            { text = "政安", comment = "zheng an" },
            { text = "郑安", comment = "zheng an" },
            { text = "郑庵", comment = "zheng an" },
            { text = "征安", comment = "zheng an" },
        },
        ["zheng ao"] = {
            { text = "郑傲", comment = "zheng ao" },
            { text = "郑遨", comment = "zheng ao" },
            { text = "正奥", comment = "zheng ao" },
        },
        ["zheng bu"] = {
            { text = "整不", comment = "zheng bu" },
            { text = "整部", comment = "zheng bu" },
            { text = "正步", comment = "zheng bu" },
            { text = "郑部", comment = "zheng bu" },
            { text = "整补", comment = "zheng bu" },
            { text = "正部", comment = "zheng bu" },
            { text = "正补", comment = "zheng bu" },
        },
        ["zheng e"] = {
            { text = "郑愕", comment = "zheng e" },
        },
        ["zheng huai"] = {
            { text = "整坏", comment = "zheng huai" },
        },
        ["zheng ou"] = {
            { text = "正欧", comment = "zheng ou" },
        },
        ["zheng ri"] = {
            { text = "整日", comment = "zheng ri" },
            { text = "正日", comment = "zheng ri" },
        },
        ["zheng wo"] = {
            { text = "整我", comment = "zheng wo" },
        },
        ["zheng xu"] = {
            { text = "郑旭", comment = "zheng xu" },
            { text = "正序", comment = "zheng xu" },
            { text = "正旭", comment = "zheng xu" },
            { text = "郑许", comment = "zheng xu" },
            { text = "郑徐", comment = "zheng xu" },
        },
        ["zheng ye"] = {
            { text = "整页", comment = "zheng ye" },
            { text = "整夜", comment = "zheng ye" },
            { text = "正业", comment = "zheng ye" },
            { text = "正野", comment = "zheng ye" },
            { text = "正页", comment = "zheng ye" },
            { text = "郑烨", comment = "zheng ye" },
            { text = "郑叶", comment = "zheng ye" },
        },
        ["zhi bu"] = {
            { text = "支部", comment = "zhi bu" },
            { text = "止步", comment = "zhi bu" },
            { text = "织布", comment = "zhi bu" },
            { text = "只补", comment = "zhi bu" },
            { text = "直补", comment = "zhi bu" },
            { text = "织补", comment = "zhi bu" },
            { text = "值不", comment = "zhi bu" },
            { text = "直埠", comment = "zhi bu" },
            { text = "智布", comment = "zhi bu" },
        },
        ["zhi dao ba"] = {
            { text = "知道吧", comment = "zhi dao ba" },
        },
        ["zhi dao o a"] = {
            { text = "知道哦啊", comment = "zhi dao o a" },
        },
        ["zhi huai"] = {
            { text = "治淮", comment = "zhi huai" },
        },
        ["zhi ou"] = {
            { text = "止呕", comment = "zhi ou" },
            { text = "致欧", comment = "zhi ou" },
        },
        ["zhi ri"] = {
            { text = "之日", comment = "zhi ri" },
            { text = "值日", comment = "zhi ri" },
            { text = "知日", comment = "zhi ri" },
        },
        ["zhong bu"] = {
            { text = "中部", comment = "zhong bu" },
            { text = "中不", comment = "zhong bu" },
            { text = "钟部", comment = "zhong bu" },
            { text = "中布", comment = "zhong bu" },
            { text = "众埠", comment = "zhong bu" },
        },
        ["zhong di"] = {
            { text = "种地", comment = "zhong di" },
            { text = "中低", comment = "zhong di" },
            { text = "重地", comment = "zhong di" },
            { text = "中底", comment = "zhong di" },
            { text = "中地", comment = "zhong di" },
            { text = "中迪", comment = "zhong di" },
            { text = "众地", comment = "zhong di" },
        },
        ["zhong dong bu"] = {
            { text = "中东部", comment = "zhong dong bu" },
        },
        ["zhong dong ou"] = {
            { text = "中东欧", comment = "zhong dong ou" },
        },
        ["zhong ei"] = {
            { text = "中诶", comment = "zhong ei" },
        },
        ["zhong huai"] = {
            { text = "仲怀", comment = "zhong huai" },
            { text = "中淮", comment = "zhong huai" },
        },
        ["zhong ou"] = {
            { text = "中欧", comment = "zhong ou" },
        },
        ["zhong ri"] = {
            { text = "中日", comment = "zhong ri" },
            { text = "终日", comment = "zhong ri" },
        },
        ["zhou bu"] = {
            { text = "肘部", comment = "zhou bu" },
            { text = "周部", comment = "zhou bu" },
            { text = "绉布", comment = "zhou bu" },
        },
        ["zhou ou"] = {
            { text = "周偶", comment = "zhou ou" },
        },
        ["zhu ao"] = {
            { text = "猪獒", comment = "zhu ao" },
            { text = "珠岙", comment = "zhu ao" },
        },
        ["zhu ban"] = {
            { text = "主板", comment = "zhu ban" },
            { text = "主办", comment = "zhu ban" },
            { text = "主班", comment = "zhu ban" },
            { text = "助班", comment = "zhu ban" },
            { text = "竹板", comment = "zhu ban" },
            { text = "主瓣", comment = "zhu ban" },
            { text = "主版", comment = "zhu ban" },
        },
        ["zhu bao"] = {
            { text = "珠宝", comment = "zhu bao" },
            { text = "猪宝", comment = "zhu bao" },
            { text = "朱宝", comment = "zhu bao" },
            { text = "住保", comment = "zhu bao" },
            { text = "朱保", comment = "zhu bao" },
            { text = "主堡", comment = "zhu bao" },
            { text = "主包", comment = "zhu bao" },
        },
        ["zhu bei"] = {
            { text = "贮备", comment = "zhu bei" },
            { text = "主备", comment = "zhu bei" },
            { text = "朱贝", comment = "zhu bei" },
            { text = "朱蓓", comment = "zhu bei" },
            { text = "竹北", comment = "zhu bei" },
            { text = "注备", comment = "zhu bei" },
        },
        ["zhu ben"] = {
            { text = "朱本", comment = "zhu ben" },
            { text = "逐本", comment = "zhu ben" },
            { text = "竹本", comment = "zhu ben" },
            { text = "铸本", comment = "zhu ben" },
        },
        ["zhu bin"] = {
            { text = "朱斌", comment = "zhu bin" },
            { text = "朱彬", comment = "zhu bin" },
            { text = "主宾", comment = "zhu bin" },
            { text = "祝斌", comment = "zhu bin" },
        },
        ["zhu bu"] = {
            { text = "逐步", comment = "zhu bu" },
            { text = "主布", comment = "zhu bu" },
            { text = "住不", comment = "zhu bu" },
            { text = "主簿", comment = "zhu bu" },
            { text = "煮布", comment = "zhu bu" },
            { text = "竹布", comment = "zhu bu" },
        },
        ["zhu fo"] = {
            { text = "诸佛", comment = "zhu fo" },
        },
        ["zhu nin"] = {
            { text = "祝您", comment = "zhu nin" },
            { text = "助您", comment = "zhu nin" },
        },
        ["zhu niu"] = {
            { text = "猪妞", comment = "zhu niu" },
        },
        ["zhu nuo"] = {
            { text = "朱诺", comment = "zhu nuo" },
        },
        ["zhu ou"] = {
            { text = "朱鸥", comment = "zhu ou" },
        },
        ["zhu su bei"] = {
            { text = "注塑杯", comment = "zhu su bei" },
        },
        ["zhu suo di"] = {
            { text = "住所地", comment = "zhu suo di" },
        },
        ["zhu ya"] = {
            { text = "蛀牙", comment = "zhu ya" },
            { text = "朱亚", comment = "zhu ya" },
            { text = "猪呀", comment = "zhu ya" },
            { text = "朱雅", comment = "zhu ya" },
            { text = "猪牙", comment = "zhu ya" },
            { text = "朱娅", comment = "zhu ya" },
        },
        ["zhu yan"] = {
            { text = "主演", comment = "zhu yan" },
            { text = "朱燕", comment = "zhu yan" },
            { text = "朱艳", comment = "zhu yan" },
            { text = "助研", comment = "zhu yan" },
            { text = "朱岩", comment = "zhu yan" },
            { text = "朱颜", comment = "zhu yan" },
            { text = "驻颜", comment = "zhu yan" },
            { text = "朱妍", comment = "zhu yan" },
            { text = "竹盐", comment = "zhu yan" },
            { text = "朱彦", comment = "zhu yan" },
            { text = "朱厌", comment = "zhu yan" },
            { text = "朱炎", comment = "zhu yan" },
            { text = "祝燕", comment = "zhu yan" },
            { text = "朱琰", comment = "zhu yan" },
        },
        ["zhu ye ye"] = {
            { text = "猪爷爷", comment = "zhu ye ye" },
        },
        ["zhu yi a"] = {
            { text = "注意啊", comment = "zhu yi a" },
        },
        ["zhu yin"] = {
            { text = "注音", comment = "zhu yin" },
            { text = "朱茵", comment = "zhu yin" },
            { text = "主因", comment = "zhu yin" },
            { text = "主音", comment = "zhu yin" },
            { text = "主印", comment = "zhu yin" },
            { text = "朱银", comment = "zhu yin" },
            { text = "朱音", comment = "zhu yin" },
            { text = "烛阴", comment = "zhu yin" },
            { text = "助印", comment = "zhu yin" },
            { text = "主银", comment = "zhu yin" },
            { text = "主淫", comment = "zhu yin" },
        },
        ["zhu you"] = {
            { text = "猪油", comment = "zhu you" },
            { text = "住友", comment = "zhu you" },
            { text = "注油", comment = "zhu you" },
            { text = "著有", comment = "zhu you" },
            { text = "筑友", comment = "zhu you" },
            { text = "助友", comment = "zhu you" },
            { text = "朱友", comment = "zhu you" },
            { text = "祝由", comment = "zhu you" },
            { text = "诸由", comment = "zhu you" },
        },
        ["zhu yuan"] = {
            { text = "祝愿", comment = "zhu yuan" },
            { text = "住院", comment = "zhu yuan" },
            { text = "竹园", comment = "zhu yuan" },
            { text = "竹苑", comment = "zhu yuan" },
            { text = "朱元", comment = "zhu yuan" },
            { text = "朱媛", comment = "zhu yuan" },
            { text = "朱院", comment = "zhu yuan" },
            { text = "朱源", comment = "zhu yuan" },
            { text = "主院", comment = "zhu yuan" },
            { text = "竹源", comment = "zhu yuan" },
            { text = "朱园", comment = "zhu yuan" },
            { text = "主元", comment = "zhu yuan" },
            { text = "铸源", comment = "zhu yuan" },
            { text = "朱鸢", comment = "zhu yuan" },
        },
        ["zhua nie"] = {
            { text = "抓捏", comment = "zhua nie" },
        },
        ["zhua niu"] = {
            { text = "抓牛", comment = "zhua niu" },
        },
        ["zhua ta"] = {
            { text = "抓他", comment = "zhua ta" },
        },
        ["zhua tou"] = {
            { text = "抓头", comment = "zhua tou" },
        },
        ["zhuan ye"] = {
            { text = "专业", comment = "zhuan ye" },
            { text = "转业", comment = "zhuan ye" },
            { text = "专页", comment = "zhuan ye" },
        },
        ["zhuan yu"] = {
            { text = "颛臾", comment = "zhuan yu" },
            { text = "转喻", comment = "zhuan yu" },
        },
        ["zhuang a"] = {
            { text = "装啊", comment = "zhuang a" },
        },
        ["zhuang bu"] = {
            { text = "装不", comment = "zhuang bu" },
            { text = "装补", comment = "zhuang bu" },
            { text = "撞布", comment = "zhuang bu" },
        },
        ["zhuang huai"] = {
            { text = "撞坏", comment = "zhuang huai" },
            { text = "壮怀", comment = "zhuang huai" },
        },
        ["zhuang ri"] = {
            { text = "撞日", comment = "zhuang ri" },
        },
        ["zhui a"] = {
            { text = "追啊", comment = "zhui a" },
        },
        ["zhui an"] = {
            { text = "追案", comment = "zhui an" },
        },
        ["zhui bu"] = {
            { text = "追捕", comment = "zhui bu" },
            { text = "追补", comment = "zhui bu" },
        },
        ["zhui die"] = {
            { text = "追跌", comment = "zhui die" },
        },
        ["zhui huai"] = {
            { text = "追怀", comment = "zhui huai" },
        },
        ["zhui ri"] = {
            { text = "追日", comment = "zhui ri" },
        },
        ["zhui xu"] = {
            { text = "赘婿", comment = "zhui xu" },
            { text = "追叙", comment = "zhui xu" },
        },
        ["zhui ya"] = {
            { text = "坠崖", comment = "zhui ya" },
        },
        ["zhui yu"] = {
            { text = "追鱼", comment = "zhui yu" },
            { text = "赘余", comment = "zhui yu" },
        },
        ["zhun wo"] = {
            { text = "准我", comment = "zhun wo" },
        },
        ["zhun yu"] = {
            { text = "准予", comment = "zhun yu" },
            { text = "准予", comment = "zhun yu" },
        },
        ["zhuo an"] = {
            { text = "桌案", comment = "zhuo an" },
            { text = "卓安", comment = "zhuo an" },
        },
        ["zhuo ao"] = {
            { text = "卓奥", comment = "zhuo ao" },
        },
        ["zhuo bu"] = {
            { text = "桌布", comment = "zhuo bu" },
        },
        ["zhuo di"] = {
            { text = "桌底", comment = "zhuo di" },
        },
        ["zhuo en"] = {
            { text = "卓恩", comment = "zhuo en" },
        },
        ["zhuo ou"] = {
            { text = "卓欧", comment = "zhuo ou" },
        },
        ["zhuo yu"] = {
            { text = "捉鱼", comment = "zhuo yu" },
            { text = "卓宇", comment = "zhuo yu" },
            { text = "卓誉", comment = "zhuo yu" },
            { text = "琢玉", comment = "zhuo yu" },
            { text = "卓玉", comment = "zhuo yu" },
            { text = "卓裕", comment = "zhuo yu" },
        },
        ["zi bu"] = {
            { text = "滋补", comment = "zi bu" },
            { text = "自补", comment = "zi bu" },
            { text = "子部", comment = "zi bu" },
            { text = "梓埠", comment = "zi bu" },
            { text = "孳逋", comment = "zi bu" },
        },
        ["zi huai"] = {
            { text = "自怀", comment = "zi huai" },
        },
        ["zi ou"] = {
            { text = "自耦", comment = "zi ou" },
        },
        ["zi ri"] = {
            { text = "紫日", comment = "zi ri" },
        },
        ["zong bu"] = {
            { text = "总部", comment = "zong bu" },
            { text = "总不", comment = "zong bu" },
            { text = "纵步", comment = "zong bu" },
        },
        ["zong ou"] = {
            { text = "宗鸥", comment = "zong ou" },
        },
        ["zou bu"] = {
            { text = "走不", comment = "zou bu" },
            { text = "走步", comment = "zou bu" },
            { text = "邹部", comment = "zou bu" },
        },
        ["zou ou"] = {
            { text = "邹鸥", comment = "zou ou" },
        },
        ["zu ba"] = {
            { text = "组吧", comment = "zu ba" },
        },
        ["zu bai"] = {
            { text = "租摆", comment = "zu bai" },
        },
        ["zu ban"] = {
            { text = "组办", comment = "zu ban" },
            { text = "组班", comment = "zu ban" },
            { text = "组板", comment = "zu ban" },
        },
        ["zu bao"] = {
            { text = "组包", comment = "zu bao" },
            { text = "租宝", comment = "zu bao" },
        },
        ["zu bei"] = {
            { text = "祖辈", comment = "zu bei" },
            { text = "足背", comment = "zu bei" },
        },
        ["zu ben"] = {
            { text = "足本", comment = "zu ben" },
            { text = "祖本", comment = "zu ben" },
        },
        ["zu bie"] = {
            { text = "组别", comment = "zu bie" },
            { text = "族别", comment = "zu bie" },
        },
        ["zu bin"] = {
            { text = "祖斌", comment = "zu bin" },
        },
        ["zu nei"] = {
            { text = "组内", comment = "zu nei" },
        },
        ["zu yan"] = {
            { text = "祖研", comment = "zu yan" },
        },
        ["zu ye"] = {
            { text = "祖业", comment = "zu ye" },
            { text = "组野", comment = "zu ye" },
            { text = "卒业", comment = "zu ye" },
        },
        ["zu yin"] = {
            { text = "足银", comment = "zu yin" },
            { text = "足印", comment = "zu yin" },
        },
        ["zu you"] = {
            { text = "足有", comment = "zu you" },
        },
        ["zu yu ye"] = {
            { text = "足浴液", comment = "zu yu ye" },
        },
        ["zu yuan"] = {
            { text = "组员", comment = "zu yuan" },
            { text = "组员", comment = "zu yuan" },
        },
        ["zu yue"] = {
            { text = "租约", comment = "zu yue" },
            { text = "足月", comment = "zu yue" },
        },
        ["zui an"] = {
            { text = "罪案", comment = "zui an" },
        },
        ["zui bu"] = {
            { text = "最不", comment = "zui bu" },
            { text = "嘴部", comment = "zui bu" },
        },
        ["zui e"] = {
            { text = "罪恶", comment = "zui e" },
            { text = "醉鹅", comment = "zui e" },
        },
        ["zui ne"] = {
            { text = "嘴呢", comment = "zui ne" },
        },
        ["zui nie"] = {
            { text = "罪孽", comment = "zui nie" },
        },
        ["zui ou"] = {
            { text = "嘴鸥", comment = "zui ou" },
            { text = "嘴鸥", comment = "zui ou" },
        },
        ["zui xu"] = {
            { text = "最需", comment = "zui xu" },
        },
        ["zui yu"] = {
            { text = "罪域", comment = "zui yu" },
            { text = "醉鱼", comment = "zui yu" },
        },
        ["zun di"] = {
            { text = "尊邸", comment = "zun di" },
        },
        ["zuo a"] = {
            { text = "做啊", comment = "zuo a" },
        },
        ["zuo ai"] = {
            { text = "做爱", comment = "zuo ai" },
            { text = "左爱", comment = "zuo ai" },
            { text = "作爱", comment = "zuo ai" },
        },
        ["zuo an"] = {
            { text = "左岸", comment = "zuo an" },
            { text = "作案", comment = "zuo an" },
            { text = "左安", comment = "zuo an" },
        },
        ["zuo ao"] = {
            { text = "左傲", comment = "zuo ao" },
        },
        ["zuo bu"] = {
            { text = "做不", comment = "zuo bu" },
        },
        ["zuo di"] = {
            { text = "坐地", comment = "zuo di" },
            { text = "做低", comment = "zuo di" },
            { text = "做底", comment = "zuo di" },
            { text = "作的", comment = "zuo di" },
        },
        ["zuo en"] = {
            { text = "佐恩", comment = "zuo en" },
        },
        ["zuo huai"] = {
            { text = "坐怀", comment = "zuo huai" },
            { text = "做坏", comment = "zuo huai" },
            { text = "左踝", comment = "zuo huai" },
        },
        ["zuo ou"] = {
            { text = "作呕", comment = "zuo ou" },
        },
        ["zuo ri"] = {
            { text = "昨日", comment = "zuo ri" },
        },
        ["zuo ye"] = {
            { text = "作业", comment = "zuo ye" },
            { text = "昨夜", comment = "zuo ye" },
            { text = "做野", comment = "zuo ye" },
            { text = "左叶", comment = "zuo ye" },
            { text = "做嘢", comment = "zuo ye" },
            { text = "佐野", comment = "zuo ye" },
            { text = "坐夜", comment = "zuo ye" },
        },
        ["zuo yu"] = {
            { text = "做鱼", comment = "zuo yu" },
            { text = "坐浴", comment = "zuo yu" },
            { text = "作于", comment = "zuo yu" },
            { text = "坐于", comment = "zuo yu" },
        },
    }
end

function M.func(input, env)
    for cand in input:iter() do
        -- 获取当前候选项的拼音（假设拼音被［］包围）
        local pinyin = cand.comment:match("^［(.-)］$")
        if pinyin and #pinyin > 0 then
            local correction_pinyin = pinyin
            if env.delimiter then
                -- 如果有分隔符，则用空格替代分隔符
                correction_pinyin = correction_pinyin:gsub(env.delimiter, ' ')
            end

            local corrections = M.corrections[correction_pinyin]
            if corrections then
                -- 遍历所有修正项并匹配
                for _, c in ipairs(corrections) do
                    if cand.text == c.text then
                        -- 如果匹配，则修改候选项的注释
                        cand:get_genuine().comment = string.gsub(M.style, "{comment}", c.comment)
                        break  -- 找到匹配的修正项后就跳出循环
                    end
                end
            else
                -- 如果没有找到修正项，按配置决定是否保留原拼音注释
                if env.keep_comment then
                    cand:get_genuine().comment = string.gsub(M.style, "{comment}", pinyin)
                else
                    cand:get_genuine().comment = ""
                end
            end
        end
        yield(cand)
    end
end

return M
