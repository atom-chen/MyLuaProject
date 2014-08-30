--�๦��label�ռ�
--2012.1.14
--�ĳ�module ����CCLayer���� ȥ��Lua��Table
module("MultiLabel", package.seeall)

--xml�ַ�������
--[[
<label color='0,255,0' userdata='aaaa' tag='11' class='true' fontname='' fontsize=''>[MyName]</label>
<image src='temp/001.png' size='123,421'/>
]]
--˵��
--label��ǩ����Ҫ���ı�����
--������:
--color 		��ɫ
--fontname 		����
--fontname 		�ֺ�
--tag  			tagֵ
--class 		��class��Ϊ��ʱ��label��ʾ����linklabel��������class�ķ���
--userdata 		��class��Ϊ��ʱ������linklable��userdata

--��ǩֵΪ�ı����ݣ�classΪ��ʱ֧��\r\n �� \n ����


--image��ǩ ��isani����Ϊ�ջ��߲�Ϊtrueʱ��src�����isaniΪtrueʱ�������ؼ����봫���ö����ķ���
--�����У�
--isani		�Ƿ��Ƕ���
--src 		ͼƬ·��
--size		��ʽ��width,height ����ͼƬ��С
--userdata

--����(*��Ϊ����)�� xml��ʽ���͵�string(*)�����(*)�����壬�ֺţ�ÿ�еļ��,��ö����ķ����������ش�userdata������
function new(content,width,fontname,fontsize,nYSpace,getAniSpriteFunc, userFunc)
	if fontname == nil then	
		fontname = FONT_NAME;
	end
	if fontsize == nil then	
		fontsize = FONT_SIZE_L;
	end
	if nYSpace == nil then --���ؼ�yλ�õļ��
		nYSpace = SY(1)
	end
	
	local layer = CCLayer:create()
	layer:setContentSize(SZ(width,SY(1)))  --��ʱ��С
	
	local xmlTable=XmlParser:ParseXmlText(content) --xml�ַ�������
	if #xmlTable > 0 then
		local nWidth=0 --��ǰ�еĿ��
		local nControlTable={} --������еĿؼ�
		local nLine = 1;	
		local maxWidth=0;		
		for key,value in pairs(xmlTable) do			
			--ȡ������
			local color = nil;
			local fname = nil;
			local fsize = nil;
			local userdata = nil;
			local tag = nil;
			local class = nil;			
			local src = nil;
			local size = nil;
			local text = value.Value;
			local isani=nil;
			
			for k,v in pairs(value.Attributes) do 
				k = string.lower(k)
				if k == "color" then
					color = v;					
				elseif k == "fontname" then
					fname = v;					
				elseif k == "fontsize" then
				    if string.len(v) > 0 then
					    fsize = GGetFontSize(tonumber(v));	
                    end				
				elseif k == "userdata" then
					userdata = v; --Font.Split( v,",");
				elseif k == "tag" then
					tag = v;
				elseif k == "class" then
					class = v;				
				elseif k == "src" then
					src = v;
				elseif k == "size" then
					size = v;
				elseif k == "isani" then
					isani = string.lower(v);
				end
			end
			--һЩ���Դ��������õĶ���Ĭ��ֵ
			if color == nil or color == "" then
				color = ccc3(255,255,255)
			else
				color = Font.Split(color,",")
				color = ccc3(color[1],color[2],color[3]);
			end
			if fname == nil or fname == "" then
				fname = fontname
			end
			if fsize == nil or fsize == "" then
				fsize = fontsize
			end
			
			if nControlTable[nLine] == nil then				
				nControlTable[nLine]={}
				nControlTable[nLine].height=0;
				nControlTable[nLine].items={};
			end
			
			-- local control = nil;
			if value.Name == "label" then
				if class ~= nil and class ~= "" and text ~= nil then  --���class��ֵ��Ϊlinklabel����
					local linkLabel=LinkLabel.new(text,color,fname,fsize)
					local csize=linkLabel:getContentSize();
					if csize.width + nWidth > width  then
						nLine = nLine + 1;
						nControlTable[nLine]={}
						nControlTable[nLine].height=0;
						nControlTable[nLine].items={};
						nWidth = csize.width
						maxWidth=width
					else
						nWidth = nWidth + csize.width
						if nWidth > maxWidth then
							maxWidth = nWidth;
						end
					end
					if csize.height > nControlTable[nLine].height then
						nControlTable[nLine].height = csize.height;
					end
					table.insert(nControlTable[nLine].items,{item=linkLabel,sacelX=1,sacelY=1})
					local function LinkLabelCallback(tag, userdata)
						userFunc(tag, userdata)
					end
					linkLabel:setFunc(LinkLabelCallback);
					if userdata then
						linkLabel:setData(Font.Split(userdata,","))
					end					
					if tag then
						linkLabel:setMenuItemTag(tag)
					end
					
					linkLabel:setPosition(ccp(0,0))--����ʱ��һ��λ�� ֮������λ��
					linkLabel:addto(layer)					
				else
					--/r/n /n����
					if text and Font.stringTrim(text) ~= "" then
                        local textTable=Font.Split(string.gsub(text,"\r\n","\n"),"\n")
                        for index,strText in pairs(textTable) do
                            while true do
                                local labelStr,str=Font.subString(strText,width - nWidth , fname, fsize);
                                strText = str;
                                if labelStr == nil or labelStr == "" then
                                    nLine = nLine + 1;
                                    nWidth = 0;
                                    nControlTable[nLine]={}
                                    nControlTable[nLine].height=0;
                                    nControlTable[nLine].items={};							
                                else
                                    local label = CCLabelTTF:create(labelStr, fname, fsize)
                                    local csize=label:getContentSize();							
                                    nWidth = nWidth + csize.width		
									if nWidth > maxWidth then
										maxWidth = nWidth;
									end
                                    if csize.height > nControlTable[nLine].height then
                                        nControlTable[nLine].height = csize.height;
                                    end
                                    table.insert(nControlTable[nLine].items,{item=label,sacelX=1,sacelY=1})
                                    if tag and string.len(tag) > 0 then
                                        label:setTag(tag)
                                    end
                                    label:setColor(color);
                                    label:setAnchorPoint(ccp(0,0))
                                    label:setPosition(ccp(0,0))--����ʱ��һ��λ�� ֮������λ��
                                    layer:addChild(label,0)	
                                end	
                                if strText == nil or strText == "" then
                                    break;
                                end
                            end
                            if index<#textTable then
                                nLine = nLine + 1;
                                nWidth = 0;
                                nControlTable[nLine]={}
                                nControlTable[nLine].height=0;
                                nControlTable[nLine].items={};
								maxWidth=width
                            end
                        end
					end
				end
			elseif value.Name == "image" then
				local img=nil
				if isani == "true" then
					img = getAniSpriteFunc(userdata);
				else
					img = CCSprite:create(P(src));
				end
				local scalex=1
				local scaley=1
				if size then
					size=Font.Split(size,",")
					scalex=tonumber(size[1])/img:getContentSize().width
					scaley=tonumber(size[2])/img:getContentSize().height
					img:setScaleX(scalex)
					img:setScaleY(scaley)
				end
				
				local csize=img:getContentSize();
				if csize.width*scalex + nWidth > width  then
					nLine = nLine + 1;
					nControlTable[nLine]={}
					nControlTable[nLine].height=0;
					nControlTable[nLine].items={};
					nWidth = csize.width*scalex
					maxWidth=width
				else
					nWidth = nWidth + csize.width*scalex
					if nWidth > maxWidth then
						maxWidth = nWidth;
					end
				end
				if csize.height*scaley > nControlTable[nLine].height then
					nControlTable[nLine].height = csize.height*scaley;
				end
				if tag then
					img:setTag(tag)
				end
				table.insert(nControlTable[nLine].items,{item=img,sacelX=scalex,sacelY=scaley})
				img:setAnchorPoint(ccp(0,0))
				img:setPosition(ccp(0,0))--����ʱ��һ��λ�� ֮������λ��
				layer:addChild(img,0)	
			end			
		end	
		--�ȱ���һ�μ���layer�߶�
		local layerHeight=0
		for key,value in pairs(nControlTable) do
			layerHeight = value.height + layerHeight
		end
		layerHeight = layerHeight + (#nControlTable-1)*nYSpace;
		layer:setContentSize(SZ(maxWidth,layerHeight))
		--�������пؼ�����position
		local offy = layerHeight;
		for key,value in pairs(nControlTable) do
			local offx=0
			offy = offy - value.height/2;
			for k,v in pairs (value.items) do
				v.item:setPosition(ccp(offx,offy-v.item:getContentSize().height*v.sacelY/2))
				offx = offx + v.item:getContentSize().width*v.sacelX;
			end			
			offy = offy - value.height/2 - nYSpace;
		end
	end	
	--���ݾɽӿ� 
	--��parent:addChild(layer, 0)
	function layer:addto(parent, param1, param2)
		if type(param1) == "userdata" then
			parent:addChildItem(self, param1)
		else
			if param2 then
				parent:addChild(self, param1, param2)
			elseif param1 then
				parent:addChild(self, param1)
			else
				parent:addChild(self, 0)
			end
		end
	end

	function layer:getLayer()
		return self
	end

	return layer
end
