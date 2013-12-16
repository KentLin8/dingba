###
#
# 後端javascript設定
#
#= require jquery
#= require jquery_ujs
# require jquery.validate.min
#= require jquery.ui.datepicker
#= require jquery.ui.sortable
#= require jquery.ui.tabs
#= require jquery.ui.draggable
#= require bootstrap-tooltip
#= require bootstrap-dropdown
#= require fileuploader
#= require application
#= require_self
###

cities =
  '臺北市':['松山區','信義區','大安區','中山區','中正區','大同區','萬華區','文山區','南港區','內湖區','士林區','北投區']
  '高雄市':['鹽埕區','鼓山區','左營區','楠梓區','三民區','新興區','前金區','苓雅區','前鎮區','旗津區','小港區','鳳山區','林園區','大寮區','大樹區','大社區','仁武區','鳥松區','岡山區','橋頭區','燕巢區','田寮區','阿蓮區','路竹區','湖內區','茄萣區','永安區','彌陀區','梓官區','旗山區','美濃區','六龜區','甲仙區','杉林區','內門區','茂林區','桃源區','那瑪夏']
  '新北市':["板橋區", "新莊區", "泰山區", "林口區", "淡水區", "金山區", "八里區", "萬里區", "石門區", "三芝區", "瑞芳區", "汐止區", "平溪區", "貢寮區", "雙溪區", "深坑區", "石碇區", "新店區", "坪林區", "烏來區", "中和區", "永和區", "土城區", "三峽區", "樹林區", "鶯歌區", "三重區", "蘆洲區", "五股區"]
  '臺中市':["中區", "東區", "南區", "西區", "北區", "北屯區", "西屯區", "南屯區", "太平區", "大里區", "霧峰區", "烏日區", "豐原區", "后里區", "東勢區", "石岡區", "新社區", "和平區", "神岡區", "潭子區", "大雅區", "大肚區", "龍井區", "沙鹿區", "梧棲區", "清水區", "大甲區", "外埔區", "大安區"]
  "臺南市": ["中西區", "東區", "南區", "北區", "安平區", "安南區", "永康區", "歸仁區", "新化區", " 左鎮區", "玉井區", "楠西區", "南化區", "仁德區", "關廟區", "龍崎區", "官田區", "麻豆區", " 佳里區", "西港區", "七股區", "將軍區", "學甲區", "北門區", "新營區", "後壁區", "白河區", " 東山區", "六甲區", "下營區", "柳營區", "鹽水區", "善化區", "大內區", "山上區", "新市區", "安定區"]
  "宜蘭縣": ["宜蘭市", "羅東鎮", "蘇澳鎮", "頭城鎮", "礁溪鄉", "壯圍鄉", "員山鄉", "冬山鄉", "五結鄉", "三星鄉", "大同鄉", "南澳鄉"]
  "桃園縣": ["桃園市", "中壢市", "平鎮市", "八德市", "楊梅市", "大溪鎮", "蘆竹鄉", "龍潭鄉", "龜山鄉", "大園鄉", "觀音鄉", "新屋鄉", "復興鄉"]
  "新竹縣": ["竹北市", "竹東鎮", "新埔鎮", "關西鎮", "新豐鄉", "峨眉鄉", "寶山鄉", "五峰鄉", "橫山鄉", "北埔鄉", "尖石鄉", "芎林鄉", "湖口鄉"]
  "苗栗縣": ["苗栗市", "通霄鎮", "苑裡鎮", "竹南鎮", "頭份鎮", "後龍鎮", "卓蘭鎮", "西湖鄉", "頭屋鄉", "公館鄉", "銅鑼鄉", "三義鄉", "造橋鄉", "三灣鄉", "南庄鄉", "大湖鄉", "獅潭鄉", "泰安鄉"]
  "彰化縣": ["彰化市", "員林鎮", "和美鎮", "鹿港鎮", "溪湖鎮", "二林鎮", "田中鎮", "北斗鎮", "花壇鄉", "芬園鄉", "大村鄉", "永靖鄉", "伸港鄉", "線西鄉", "福興鄉", "秀水鄉", "埔心鄉", "埔鹽鄉", "大城鄉", "芳苑鄉", "竹塘鄉", "社頭鄉", "二水鄉", "田尾鄉", "埤頭鄉", "溪州鄉"]
  "南投縣": ["南投市", "埔里鎮", "草屯鎮", "竹山鎮", "集集鎮", "名間鄉", "鹿谷鄉", "中寮鄉", "魚池鄉", "國姓鄉", "水里鄉", "信義鄉", "仁愛鄉"]
  "雲林縣": ["斗六市", "斗南鎮", "虎尾鎮", "西螺鎮", "土庫鎮", "北港鎮", "莿桐鄉", "林內鄉", "古坑鄉", "大埤鄉", "崙背鄉", "二崙鄉", "麥寮鄉", "臺西鄉", "東勢鄉", "褒忠鄉", "四湖鄉", "口湖鄉", "水林鄉", "元長鄉"]
  "嘉義縣": ["太保市", "朴子市", "布袋鎮", "大林鎮", "民雄鄉", "溪口鄉", "新港鄉", "六腳鄉", "東石鄉", "義竹鄉", "鹿草鄉", "水上鄉", "中埔鄉", "竹崎鄉", "梅山鄉", "番路鄉", "大埔鄉", "阿里山鄉"]
  "屏東縣": ["屏東市", "潮州鎮", "東港鎮", "恆春鎮", "萬丹鄉", "長治鄉", "麟洛鄉", "九如鄉", "里港鄉", "鹽埔鄉", "高樹鄉", "萬巒鄉", "內埔鄉", "竹田鄉", "新埤鄉", "枋寮鄉", "新園鄉", "崁頂鄉", "林邊鄉", "南州鄉", "佳冬鄉", "琉球鄉", "車城鄉", "滿州鄉", "枋山鄉", "霧台鄉", "瑪家鄉", "泰武鄉", "來義鄉", "春日鄉", "獅子鄉", "牡丹鄉", "三地門鄉"]
  "臺東縣": ["臺東市", "成功鎮", "關山鎮", "長濱鄉", "海端鄉", "池上鄉", "東河鄉", "鹿野鄉", "延平鄉", "卑南鄉", "金峰鄉", "大武鄉", "達仁鄉", "綠島鄉", "蘭嶼鄉", "太麻里鄉"]
  "花蓮縣": ["花蓮市", "鳳林鎮", "玉里鎮", "新城鄉", "吉安鄉", "壽豐鄉", "秀林鄉", "光復鄉", "豐濱鄉", "瑞穗鄉", "萬榮鄉", "富里鄉", "卓溪鄉"]
  "澎湖縣": ["馬公市", "湖西鄉", "白沙鄉", "西嶼鄉", "望安鄉", "七美鄉"]
  "基隆市": ["仁愛區", "中正區", "信義區", "中山區", "安樂區", "暖暖區", "七堵區"]
  "新竹市": ["東區", "北區", "香山區"]
  "嘉義市": ["東區", "西區"]
  "連江縣": ["南竿鄉", "北竿鄉", "莒光鄉", "東引鄉"]
  "金門縣": ["金城鎮", "金湖鎮", "金沙鎮", "金寧鄉", "烈嶼鄉", "烏坵鄉"]

Date::formatDate = -> "#{this.getFullYear()}-#{this.getMonth() + 1}-#{this.getDate()}"

$ ->

  show_cover = (data) ->
    $('.placeholder img').each (index) ->
      this.src = data[index+1] || ''
      return

  hook_event = ->
    # datepicker
    $(".datepicker").datepicker(
      dateFormat: "yy-mm-dd"
      showOn: 'both'
      buttonText: '<i class="icon-calendar"></i>'
    ).change( ->
      if this.id is 'show_day'
        $.get('/calendar/restaurant_day', {select_date: this.value}, 'html')
          .done( (response) -> refresh response )
          .fail( -> alert 'fail' )
      else
        from = $('#from').val()
        to = $('#to').val()
        if from and to
          if from > to
            alert '前需比後小'
            return
          $.get('restaurant_manage/query_books_by_date', {from: from, to: to}, 'html')
            .done( (response) -> refresh response )
            .fail( -> alert 'fail' )
    )
    # 填入select
    $('select').val -> $(this).data('value')
    # 檔案上傳器設定
    if document.getElementById 'upload'
      new qq.FileUploaderBasic
        button: document.getElementById 'upload'
        action: "restaurant_manage/upload_img"
        allowedExtensions: ['jpg', 'gif', 'png']
        sizeLimit: 1048576 * 3
        customHeaders: {'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')}
        messages:
          typeError: '只能上傳 {extensions} 這幾種檔案！'
          sizeError: '最大只能上傳單檔3M'
          onLeave: '檔案正在上傳中，若是離開的話將會取消上傳'
        onUpload: ->
          $('#upload span').html('上傳中...')
        onComplete: (a, b, response) ->
          $('#upload span').html('選擇檔案上傳')
          if response.success
            show_cover response.image_path
          else if response.error
            alert "上傳失敗，原因：#{response.message}"
          else
            alert '上傳失敗了'
          return
    # sortable
    if document.getElementById 'period_set'
      $('#period_set').sortable(placeholder: "ui-state-highlight")
    # 時段設定reset
    if document.getElementById 'period_reset'
      # 記憶目前的內容
      radios = $(':radio').map -> this.checked
      select = $('select').val()
      input = $('#reserve_hour').val()
      # 點擊還原
      $('#period_reset').click (e) ->
        e.preventDefault()
        t = $('.sortable')
        len = t.length - 1
        for i in [0..len]
          $('#period_set').append(t.filter('[data-sort="' + i + '"]'))
        $(':radio').each (index) -> this.checked = radios[index]; return
        $('select').val(select)
        $('#reserve_hour').val(input)
    # 顯示地址的兩層
    if document.getElementById 'restaurant_city'
      city = $('#restaurant_city')
      if val = city.data('value')
        city.val(val)
        data = cities[$('#restaurant_city').val()]
        area = $('#restaurant_area')
        area.html ("""<option value="#{t}">#{t}</option>""" for t in data).join('')
        area.val(area.data('value'))

  refresh = (html) ->
    form_place.html $.parseHTML(html, document, true)
    hook_event()

  load_page = (url, set_href = false) ->
    $.get(url, {}, 'html')
      .done( (html) ->
        refresh html
        if set_href
          if location.href.match '#'
            tmp = location.href.split '#'
            tmp[1] = url
            location.href = tmp.join '#'
          else
            location.href += '#' + url

        setTimeout(hook_event, 200)
      )
      .fail( -> alert '連線失敗，請稍後再試' )

  form_place = $('#form_place')


  $(document).on 'submit', '#new_supply', (e) ->
    check = true
    periods = []
    $('.period').find('tr').removeClass('invalid').each ->
      _this = $(this)
      ban = true
      if _this.find(':checkbox').is(':checked')
        $(this).find('input').each -> if $(this).val() is ''
          check = false
          ban = false
          return
        alert '請填滿所有欄位' unless ban
        # 前需比後小
        # 順便儲存值準備檢查時段衝突
        periods.unshift(_this.find('select').map -> $(this).val())
        if periods[0][0] > periods[0][1]
          _this.addClass('invalid')
          check = false
          ban = false
          alert '前需比後小'
      _this.addClass('invalid') unless ban
      return

    # 時段不衝突
    for period in periods
      for period2 in periods
        for p in period2
          unless (p >= period[0] && p >= period[1]) || (p <= period[0] && p <= period[1])
            check = false
            alert '時段衝突'

    unless check
      e.preventDefault()
      e.stopImmediatePropagation()

  $("#tabs").tabs()

  $('.ans').tooltip()

  $('#lightbox_wrap').click (e) -> $(this).hide() if e.target is this

  $(document).on 'click', '#calendar td', ->
    $.get('restaurant_manage/special_time', {condition_id: $(this).attr('id'), special_day: $('#year').val() + '/' + $(this).find('.date').html()})
    .done( (response) ->
        if typeof response is 'string'
          $('#tab_time').html($.parseHTML(response, document, true))
          $('.ans').tooltip()
      )
    .fail( -> alert '資料傳遞失敗' )
    false
    $('#lightbox_wrap').show()

  if location.href.match('#')
    url = location.href.split('#').pop()
    load_page url unless url is ''


  if document.getElementById 'res_header'
    $(document).on 'submit', 'form', (e) ->
      e.preventDefault()
      unless validate(this)
        alert 'validate fail'
        return false
      $.post(this.action, $(this).serialize())
        .done( (response) ->
          if typeof response is 'string'
            refresh response
          else if typeof response is 'object'
            if response.success
              if response.attachmentPartial
                refresh response.attachmentPartial
              $('#lightbox_wrap').hide()
            else if response.error
              alert response.message
        )
        .fail( -> alert '資料傳遞失敗' )
      false

  # 將sidebar連結改用ajax處理
  $('#sidebar a').click (e) ->
    e.preventDefault()
    $('.now').removeClass('now')
    $(this).addClass('now')
    href = this.attributes.href.value
    load_page href, true unless href is '#'

  $('#sub_choice a').click ->
    $('#step1_mark').addClass('now')
    $('#step1').addClass('now')

  $('#sub_choice2 a').click ->
    $('#step3_mark').addClass('now')
    $('#step3').addClass('now')

  $('#step1').click ->
    $('#step1_mark').addClass('now')
    $('#sub_choice').children().eq(0).addClass('now')
    $('#sub_choice').animate(height: 66, 'border-width': 1)
    $('#sub_choice2').animate(height: 0, 'border-width': 0)
  $('#step2').click ->
    $('#step2_mark').addClass('now')
    $('#sub_choice').animate(height: 0, 'border-width': 0)
    $('#sub_choice2').animate(height: 0, 'border-width': 0)
  $('#step3').click ->
    $('#step3_mark').addClass('now')
    $('#sub_choice2').children().eq(0).addClass('now')
    $('#sub_choice').animate(height: 0, 'border-width': 0)
    $('#sub_choice2').animate(height: 44, 'border-width': 1)
  $('#step4').click ->
    $('#sub_choice').animate(height: 0, 'border-width': 0)
    $('#sub_choice2').animate(height: 0, 'border-width': 0)

  $('#lightbox').draggable()

  # 設定封面
  $(document).on 'click', '#pics :radio', ->
    p = $(this).parent()
    $.getJSON('restaurant_manage/image_cover_save', {cover_id: p.data('id')})
      .done( (response) ->
        if response.success
          p.find('.placeholder').css('border', '1px solid #ff0000')
        else if response.error
          alert "封面設定失敗，原因：#{response.message}"
        else
          alert '封面設定失敗'
      )
      .fail( -> alert '封面設定失敗' )

  # 刪除圖片
  $(document).on 'click', '#pics img, #pics .icon-remove', -> unless $(this).parent().children('img').attr('src') is ''
    $.getJSON('restaurant_manage/image_destroy', {pic_id: $(this).parents('.float').data('id')})
    .done( (response) ->
      if response.success
        show_cover response.image_path
      else if response.error
        alert "封面設定失敗，原因：#{response.message}"
      else
        alert '封面設定失敗'
    )
    .fail( -> alert '圖片刪除失敗' )

  $(document).on 'mouseover', '#pics .placeholder', -> unless $(this).find('img').attr('src') is ''
    $(this).find('.icon-remove').show()

  $(document).on 'mouseout', '#pics .placeholder', -> $('#pics .icon-remove').hide()

  $(document).on 'change', '#restaurant_city', ->
    data = cities[$(this).val()]
    $('#restaurant_area').html ("""<option value="#{t}">#{t}</option>""" for t in data).join('')

  $(document).on 'change', '.month_picker', ->
    y = $('#year').val()
    m = $('#month').val()
    if y? and m?
      $.get('/calendar/restaurant_month', {year: y, month: m}, 'html')
        .done( (response) -> refresh(response) )
        .fail( -> alert 'fail' )

  $(document).on 'click', '#new_condition', ->
    $.get('/restaurant_manage/supply_time', {}, 'html')
      .done( (response) -> refresh response )
      .fail( -> alert('oops! 出現錯誤了!') )

  $(document).on 'click', '.edit_condition', ->
    $.get('/restaurant_manage/supply_time', {condition_id: $(this).data('id')}, 'html')
      .done( (response) -> refresh response )
      .fail( -> alert('oops! 出現錯誤了!') )

  $(document).on 'click', '.destory_condition', ->
    $.getJSON('/restaurant_manage/destroy_condition', {condition_id: $(this).data('id')})
      .done( (response) ->
        if response.success
          refresh response.attachmentPartial
          alert(response.data)
        else if response.error
          alert(response.message)
        else
          alert('發生未預期的回應，請告知CoDream小組處理!')
      )
      .fail( -> alert('oops! 出現錯誤了!') )



