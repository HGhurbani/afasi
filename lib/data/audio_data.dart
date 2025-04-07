// lib/data/audio_data.dart

import 'supplication.dart';

/// تعريف أقسام الصوتيات مع جميع العناصر
/// يمكنك نقل جميع العناصر من ملفك الأصلي إلى هنا
 /// تعريف أقسام الصوتيات مع عينات لكل قسم
  final Map<String, List<Supplication>> audioCategories = {
    "القرآن الكريم": [
      Supplication(
        title: "آيات الشفاء في القرآن الكريم",
        audioUrl: "assets/audio/mishary13.mp3",
        textAssetPath: "assets/texts/شفاء.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "سورة الكهف",
        audioUrl: "https://www.youtube.com/watch?v=-FxEYa8joK8",
        textAssetPath: "assets/texts/كهف.txt",
      ),
      Supplication(
        title: "سورة طه",
        audioUrl:
            "https://www.youtube.com/watch?v=XMPNjBEw4vc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq",
        textAssetPath: "assets/texts/طه.txt",
      ),
      Supplication(
        title: "سورة الأنفال",
        audioUrl:
            "https://www.youtube.com/watch?v=3JaXe2h563c&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=2",
        textAssetPath: "assets/texts/الأنفال.txt",
      ),
      Supplication(
        title: "تلاوة مؤثرة من سورة المدثر",
        audioUrl:
            "https://www.youtube.com/watch?v=h4PKhfXmKgk&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=3",
        textAssetPath: "assets/texts/المدثر.txt",
      ),
      Supplication(
        title: "هذان خصمان اختصموا في ربهم | من صلاة التراويح",
        audioUrl:
            "https://www.youtube.com/watch?v=QHuxUGq4CCk&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=4",
        textAssetPath: "assets/texts/الحج.txt",
      ),
      Supplication(
        title: "سورة القيامة ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=7Iszt7GFN5Q&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=5",
        textAssetPath: "assets/texts/القيامة.txt",
      ),
      Supplication(
        title: "سورة الحاقة ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=mm5J6AoN4MM&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=6",
        textAssetPath: "assets/texts/الحاقة.txt",
      ),
      Supplication(
        title: "سورة ق ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=bdnhDm58fcQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=7",
        textAssetPath: "assets/texts/قاف.txt",
      ),
      Supplication(
        title: "سورة المدثر",
        audioUrl:
            "https://www.youtube.com/watch?v=LOOGmSCndUo&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=8",
        textAssetPath: "assets/texts/المدثر.txt",
      ),
      Supplication(
        title: "سورة المزمل ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=rOf_tzIlknI&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=9",
        textAssetPath: "assets/texts/المزمل.txt",
      ),
      Supplication(
        title: "صلاة الشفع - سورة الفلق",
        audioUrl:
            "https://www.youtube.com/watch?v=2Lv3cw-1TXA&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=10",
        textAssetPath: "assets/texts/الفلق.txt",
      ),
      Supplication(
        title: "صلاة الشفع - سورة الإخلاص",
        audioUrl:
            "https://www.youtube.com/watch?v=qHK8B3d-aQQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=11",
        textAssetPath: "assets/texts/الأخلاص.txt",
      ),
      Supplication(
        title: "سورة مريم",
        audioUrl:
            "https://www.youtube.com/watch?v=y1bHdFHCKQs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=12",
        textAssetPath: "assets/texts/مريم.txt",
      ),
      Supplication(
        title: "استجيبوا لله وللرسول",
        audioUrl:
            "https://www.youtube.com/watch?v=iLjDxArvVgQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=13",
        textAssetPath: "assets/texts/الأنفالل.txt",
      ),
      Supplication(
        title: "من سورة إبراهيم",
        audioUrl:
            "https://www.youtube.com/watch?v=SUFPYER88fs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=14",
        textAssetPath: "assets/texts/ابراهيم.txt",
      ),
      Supplication(
        title: "وَلَقَدْ أَرْسَلْنَا مُوسَى - من سورة هود",
        audioUrl:
            "https://www.youtube.com/watch?v=USc1YU_uic0&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=15",
        textAssetPath: "assets/texts/هود.txt",
      ),
      Supplication(
        title: "وإلى مدين أخاهم شعيبا - من سورة هود",
        audioUrl:
            "https://www.youtube.com/watch?v=Z3unvO35RzE&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=16",
        textAssetPath: "assets/texts/هودد.txt",
      ),
      Supplication(
        title: "والله يدعو إلى دار السلام - من سورة يونس",
        audioUrl:
            "https://www.youtube.com/watch?v=-f8E0Cg5uhs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=17",
        textAssetPath: "assets/texts/يونس.txt",
      ),
      Supplication(
        title: "للذين أحسنوا الحسنى وزيادة",
        audioUrl:
            "https://www.youtube.com/watch?v=bpMeNhKxMAE&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=18",
        textAssetPath: "assets/texts/يونسس.txt",
      ),
      Supplication(
        title: "من سورة يوسف",
        audioUrl:
            "https://www.youtube.com/watch?v=9OCsN7A2Dnc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=19",
        textAssetPath: "assets/texts/يوسف.txt",
      ),
      Supplication(
        title: "واضرب لهم مثلا رجلين",
        audioUrl:
            "https://www.youtube.com/watch?v=KxpcLKM9jp0&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=20",
        textAssetPath: "assets/texts/الكهف.txt",
      ),
      Supplication(
        title:
            "وَما مُحَمَّدٌ إِلّا رَسولٌ قَد خَلَت مِن قَبلِهِ الرُّسُلُ",
        audioUrl:
            "https://www.youtube.com/watch?v=NklF4awiEeI&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=21",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "لِكَيلا تَحزَنوا عَلىٰ ما فاتَكُم وَلا ما أَصٰابَكُم",
        audioUrl:
            "https://www.youtube.com/watch?v=R9SGnvBr0Gs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=22",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "ولو كنت فظا غليظ القلب لانفضوا من حولك",
        audioUrl:
            "https://www.youtube.com/watch?v=DwdDmjSue_w&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=23",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "لا تأكلوا الربا - سورة آل عمران",
        audioUrl:
            "https://www.youtube.com/watch?v=PPf4nwQP-Yc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=24",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "فأصلحوا بين أخويكم",
        audioUrl:
            "https://www.youtube.com/watch?v=Xn6kPxSRMek&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=25",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "سعيهم مشكوراً",
        audioUrl:
            "https://www.youtube.com/watch?v=A8vMGTn2s5I&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=26",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "وكان الإنسان عجولا",
        audioUrl:
            "https://www.youtube.com/watch?v=cDIHuNpTit8&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=27",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "ولا تقربوا مال اليتيم",
        audioUrl:
            "https://www.youtube.com/watch?v=eAvOL3Ck8Kc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=28",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "شهر رمضان الذي أنزل فيه القرآن",
        audioUrl:
            "https://www.youtube.com/watch?v=6QkmTaUUotA&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=29",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
    "الأناشيد": [
      Supplication(
        title: "عمر الفاروق",
        audioUrl:
            "https://www.youtube.com/watch?v=Gkflvn9v8Os&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR",
        textAssetPath: "assets/texts/عمر-الفاروق.txt",
      ),
      Supplication(
        title: "غردي يا روح",
        audioUrl:
            "https://www.youtube.com/watch?v=t_9-WdMqUi0&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=2",
        textAssetPath: "assets/texts/غردقي.txt",
      ),
      Supplication(
        title: "علي رضي الله عنه",
        audioUrl:
            "https://www.youtube.com/watch?v=5xJkdp_3cDA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=3",
        textAssetPath: "assets/texts/علي.txt",
      ),
      Supplication(
        title: "يا شايل الهم",
        audioUrl:
            "https://www.youtube.com/watch?v=du7vFCvH7gA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=4",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "يسعد فؤادي",
        audioUrl:
            "https://www.youtube.com/watch?v=lU279ZXlmqk&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=5",
        textAssetPath: "assets/texts/فؤادي.txt",
      ),
      Supplication(
        title: "أضفيت",
        audioUrl:
            "https://www.youtube.com/watch?v=Q94Kkb4tesc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=6",
        textAssetPath: "assets/texts/اضفيت.txt",
      ),
      Supplication(
        title: "صلوا عليه وسلموا",
        audioUrl:
            "https://www.youtube.com/watch?v=Qm0_ioxhHvc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=7",
        textAssetPath: "assets/texts/صلوا.txt",
      ),
      Supplication(
        title: "حبيبي محمد",
        audioUrl:
            "https://www.youtube.com/watch?v=rgIHozrtqXI&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=8",
        textAssetPath: "assets/texts/حبيبي.txt",
      ),
      Supplication(
        title: "آية وحكاية",
        audioUrl:
            "https://www.youtube.com/watch?v=J6q_5S_Ddj4&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=9",
        textAssetPath: "assets/texts/حكايات.txt",
      ),
      Supplication(
        title: "سيبقى اشتياقي",
        audioUrl:
            "https://www.youtube.com/watch?v=YmOWf3p1Qtg&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=10",
        textAssetPath: "assets/texts/اشتياقي.txt",
      ),
      Supplication(
        title: "سيد الأخلاق",
        audioUrl:
            "https://www.youtube.com/watch?v=gmwgiqFEEpA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=11",
        textAssetPath: "assets/texts/سيد.txt",
      ),
      Supplication(
        title: "هل لك سر عند الله",
        audioUrl:
            "https://www.youtube.com/watch?v=lRNHaFAZqhc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=12",
        textAssetPath: "assets/texts/سر.txt",
      ),
      Supplication(
        title: "سيمر هذا الوقت",
        audioUrl:
            "https://www.youtube.com/watch?v=mJhGGPOTgeU&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=13",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "طلع البدر علينا",
        audioUrl:
            "https://www.youtube.com/watch?v=XjZ1gTvbaIA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=14",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
    "الأذكار": [
      Supplication(
        title: "أذكار الصباح",
        audioUrl: "assets/audio/mishary1.mp3",
        textAssetPath: "assets/texts/صباح.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "أذكار المساء",
        audioUrl: "assets/audio/mishary2.mp3",
        textAssetPath: "assets/texts/مساء.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "اذكار النوم ",
        audioUrl: "https://www.youtube.com/watch?v=Qm6QI0so0e0",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "أذكار النوم + خواتيم سورة البقره، والملك، والسجده",
        audioUrl: "https://www.youtube.com/watch?v=lqMpe4lmTpg&t=2s",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "أصبحنا وأصبح الملك لله",
        audioUrl:
            "https://www.youtube.com/watch?v=yssu6YenZCU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=22",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "تكبيرات العيد ",
        audioUrl:
            "https://www.youtube.com/watch?v=_RxP8WQOhqU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=24",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "حبي كله لك",
        audioUrl:
            "https://www.youtube.com/watch?v=foXVsEAExoU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=31",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "لبيك",
        audioUrl:
            "https://www.youtube.com/watch?v=yzZ7iMS492c&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=56",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
    "الأدعية": [
      Supplication(
        title: "دعاء السفر",
        audioUrl: "assets/audio/mishary3.mp3",
        textAssetPath: "assets/texts/سفر.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "ركوب الدابه",
        audioUrl: "assets/audio/mishary4.mp3",
        textAssetPath: "assets/texts/الركوب.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دخول السوق",
        audioUrl: "assets/audio/mishary5.mp3",
        textAssetPath: "assets/texts/سوق.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دخول المسجد",
        audioUrl: "assets/audio/mishary6.mp3",
        textAssetPath: "assets/texts/المسجد.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "الاستيقاظ من النوم",
        audioUrl: "assets/audio/mishary7.mp3",
        textAssetPath: "assets/texts/بعد النوم.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء للمتوفي",
        audioUrl: "assets/audio/mishary9.mp3",
        textAssetPath: "assets/texts/المتوفي.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء نزول المطر",
        audioUrl: "assets/audio/mishary11.mp3",
        textAssetPath: "assets/texts/المطر.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء للأولاد",
        audioUrl: "assets/audio/mishary13.mp3",
        textAssetPath: "assets/texts/اولاد.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء كسوف الشمس",
        audioUrl: "assets/audio/mishary14.mp3",
        textAssetPath: "assets/texts/كسوف.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء ختم القران",
        audioUrl: "assets/audio/mishary15.mp3",
        textAssetPath: "assets/texts/ختم.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "يا من كفانا .. سيء الأسقام",
        audioUrl:
            "https://www.youtube.com/watch?v=HdQcXgTv2aw&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=10",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء لأهل غزة",
        audioUrl:
            "https://www.youtube.com/watch?v=ngJ88El_w3Q&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=28",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "الدعاء الجامع",
        audioUrl:
            "https://www.youtube.com/watch?v=Baz7RSA1jJ0&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=29",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء رؤية الهلال",
        audioUrl:
            "https://www.youtube.com/watch?v=bi_P137Xv2g&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=86",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "اللهم فرج هم المهمومين",
        audioUrl:
        "https://www.youtube.com/watch?v=4Yts6nga0mg&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=173",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء - إصدار الرحمن و الواقعة و الحديد",
        audioUrl:
        "https://www.youtube.com/watch?v=fcG_HrPe4GQ&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=170",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
    "رمضانيات": [
      Supplication(
        title: "دعاء بلوغ رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=mGYScZSGNMY&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=80",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليالي رمضان",
        audioUrl: "assets/audio/mishary10.mp3",
        textAssetPath: "assets/texts/sleep.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء ليلة 18 رمضان من جامع الشيخ زايد",
        audioUrl:
        "https://www.youtube.com/watch?v=hg8msa2AUcg&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=188",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليلة 27 رمضان من المسجد الكبير",
        audioUrl:
            "https://www.youtube.com/watch?v=NRKsCrj5iNI&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=11",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليلة 20 الراشدية بدبي",
        audioUrl:
        "https://www.youtube.com/watch?v=wpTT4onWips&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=187",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليلة 21 رمضان",
        audioUrl:
        "https://www.youtube.com/watch?v=rDExXcV1AJQ&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=163",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليلة 27",
        audioUrl:
        "https://www.youtube.com/watch?v=_8eX9qACLbE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=160",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء ليلة 29 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=TZb0KvDu2wE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=18",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "دعاء القنوت ليلة 27",
        audioUrl:
            "https://www.youtube.com/watch?v=iTFXS5DhSBk&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=19",
        textAssetPath: "assets/texts/sleep.txt",
      ),
      Supplication(
        title: "الشفع والوتر ودعاء ٢٧ رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=_faw3Mq09NM&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=69",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
    "الرقية الشرعية": [
      Supplication(
        title: "الرقية الشرعية",
        audioUrl: "assets/audio/mishary8.mp3",
        textAssetPath: "assets/texts/الرقية.txt",
        isLocalAudio: true,
      ),
      Supplication(
        title: "علاج السحر والعين والحسد",
        audioUrl: "https://www.youtube.com/watch?v=D32QyEZJg4c",
        textAssetPath: "assets/texts/sleep.txt",
      ),
    ],
  };