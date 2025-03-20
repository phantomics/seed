;; sheet.lisp
;; Seed-interfaced file - do not edit manually

(in-package #:demo.sheet)
(defvar *profile* nil)
(defvar *graph-nodes* nil)
(defvar *esgraph-nodes* nil)
(defvar *active-graph-item* nil)
(defvar *input* nil)

;; (quote
;; (list
;;  (DRAW LINE 1534114800000 1.5352056 1538067600000 1.4786885)
;;  (DRAW LINE 1534230000000 1.4762203999999999d0 1538456400000 1.5159552)
;;  (DRAW LINE 1534230000000 1.4762203999999999d0 1538456400000 1.5159552)
;; ))

:cells
(setf *cell-matrix*
      (make-array '(10 10) :initial-contents
                  '((0 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0)
                    (9 9 9 0 0 0 0 0 0 0) (4 0 0 0 0 0 0 0 0 0)
                    (5 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0)
                    (0 6 0 0 0 0 0 0 0 0) (0 7 0 0 0 0 0 0 0 0)
                    (0 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0))))
:main
(progn
(for-cells "C2.G8" "{5+⍵}")
(for-cells "A3.B4" "{3×⍵}")
)
:chart-entities
(quote
 (meta ((meta "This is a test."
              (:fx . :uicc-field) (:type :text))
        (meta "This is a test 2."
              (:fx . :uicc-field) (:type :text))
        (meta ((meta (:point-from . 10)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 20)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 11)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 21)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 12)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 22)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 13)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 23)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2))))
      (:fx . :uic-series) (:type :sortable)))
:form
(setf *profile*
      '(meta ((meta "Dave" (:title . "Name") (:name . :name) (:type :field :text))
              (meta 34 (:title . "Age") (:name . :age)
               (:type :field :numeric :integer))
              (meta "Red" (:title . "Fav. Color") (:options "Red" "Green" "Blue")
               (:name . :fav-color) (:type :select))
              (meta nil (:title . "Member?") (:name . :member) (:type :boolean))
              (meta nil (:title . "Submit") (:name . :submit)
               (:type :submit-control)))
        (:type :series :form)))
:graph-node-indices
'(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27)
#|
           (meta (:type . :option) (:options :option :switch :input :gate)
            (:fx . :uicc-select) (:name . :type)
            (:type :select :dropdown))

|#
:graph-node-template
(quote (((meta (:title . "Untitled node") (:template meta-template.customers-title))
         (meta (:image . "none") (:template meta-template.customers-image))
         (meta (:dialog . "") (:template meta-template.customers-dialog)))))
:graph-link-template
(quote (((meta (:title . "Untitled link") (:template meta-template.customers-title))
         (meta (:dialog . "") (:template meta-template.customers-dialog)))))
:graph
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "Introductory sentence")
            (:template meta-template.customers-title))
           (meta (:image . "none") (:template meta-template.customers-image))
           (meta
            (:dialog
             . "You're working the front desk at the Globus Hotel Resort when two people appear at the counter. Guests, most likely.")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Ask who?")
             (:template meta-template.customers-title))
            (meta (:dialog . "Who are you?")
             (:template meta-template.customers-dialog)))
           1)
          (((meta (:title . "Ask why?") (:fx . :uicc-field)
             (:type :text :pair :named :block))
            (meta (:dialog . "Why are you calling me?")
             (:template meta-template.customers-dialog)))
           2))
         (((meta (:title . "Why we're here")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Excuse me, we have an event scheduled here, it's happening in two weeks and we haven't received the confirmation we requested from you.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Didn't know")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"I don't have any information on that, are you sure you have a group reservation?\"")
             (:template meta-template.customers-dialog)))
           0)
          (((meta (:title . "Who are you")
             (:template meta-template.customers-title))
            (meta
             (:dialog . "\"Ok, what's the name of the group you're with?\"")
             (:template meta-template.customers-dialog)))
           3))
         (((meta (:title . "We got a receipt")
            (:template meta-template.customers-title))
           (meta (:image . "man-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"I know you got our reservation, your website gave us a receipt number. It's 9906947-XB71.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "No special instructions?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Ok, I see it in the system but there are no special instructions attached that I can see. What can I help you with?\"")
             (:template meta-template.customers-dialog)))
           6))
         (((meta (:title . "Who we are: Annapurna")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"We're organizing the 2025 Global Guru Collective for Annapurna Essential Oils. Annapurna is on a mission to use our 2000 years' Vedic study of pure plant essences to bring humankind closer to samadhi.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Let me look for it")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Ok, let me see if I can find that...\" 11")
             (:template meta-template.customers-dialog)))
           0)
          (((meta (:title . "Who are you")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Annapurna? What's that exactly?\"")
             (:template meta-template.customers-dialog)))
           4)
          (((meta (:title . "What's the event")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"What's the event you're holding?\"")
             (:template meta-template.customers-dialog)))
           5))
         (((meta (:title . "Annapurna: Gurus, not sales reps")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Annapurna is a business but it's also much more. It represents the highest and most refined path of spiritual evolution for humans. Other companies have employees, distributors, consultants or coaches, but at Annapurna, our products are conveyed to customers by the hands of our Gurus, who learn to impart the wisdom of the four jhanas along with our line of products.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "What's the event")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Ok, so what's this event you're holding?\"")
             (:template meta-template.customers-dialog)))
           5)
          (((meta (:title . "Four jhanas?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"The four jannas? Is that like a nickname for weed or something?\"")
             (:template meta-template.customers-dialog)))
           19))
         (((meta (:title . "Event description")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"It's our Global Guru Conference. This is a weekend chosen each year according to vedic astrology for our Gurus to gather, reaffirm their spiritual paths and learn how to better grow their downline.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "What do you need?")
             (:template meta-template.customers-title))
            (meta
             (:dialog . "\"Ok, so what do you need for this conference?\"")
             (:template meta-template.customers-dialog)))
           6))
         (((meta (:title . "Event requirements")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Well, it sounds like you lost the instructions we sent so we have no choice but to give you a quick summary of what we need. There are four main things: the flower petal basins, the aromatherapeutic infusions, the singing bowl ceremonies and... our required accomodation for the business intelligence program.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Petal basins?")
             (:template meta-template.customers-title))
            (meta
             (:dialog . "\"What can you tell me about these petal basins?\"")
             (:template meta-template.customers-dialog)))
           7)
          (((meta (:title . "Aromatherapy?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"What were you saying about an aromatherapy infusion?\"")
             (:template meta-template.customers-dialog)))
           8)
          (((meta (:title . "Singing bowls")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"What did you want to do with singing bowls?\"")
             (:template meta-template.customers-dialog)))
           9)
          (((meta (:title . "Business intelligence?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Business intelligence accommodations? What's that about?\"")
             (:template meta-template.customers-dialog)))
           10))
         (((meta (:title . "About req: petal basins")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"In each of the conference rooms hosting our presentations we require basins containing a blend of zinnia, lotus and passion fruit petals floating in de-ionized water. Aligned with the podium on an east-west axis, this serves to ground the spatial chakras while our speakers are presenting.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "We can do that")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Sure, we can source floral arrangements no problem. Would you like that billed per room or in a lump sum?\"")
             (:template meta-template.customers-dialog)))
           14)
          (((meta (:title . "Not our job")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"That sounds like something you should figure out with a florist or your event management company, it's not something we can really help with.\"")
             (:template meta-template.customers-dialog)))
           15))
         (((meta (:title . "About req: incense schedule")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"We come to all events equipped with industrial censers and a week's supply of our specialty incense blends. We route these censers into the HVAC systems serving the floors where our Gurus will be staying so we can keep the air infused with these scents on a Vedic horary schedule. This promotes ideal energetic balance for the gathering.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "I suppose we can")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"I suppose we can do that, let me check with our physical plant team about those censers.\"")
             (:template meta-template.customers-dialog)))
           14)
          (((meta (:title . "Health code?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Wait, you want to hook big cans of burning incense into the building HVAC system? Are you sure that doesn't break a health code or a fire code or something?\"")
             (:template meta-template.customers-dialog)))
           15))
         (((meta (:title . "About req: singing bowls")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Our Gurus will be staying on floors two through eight in Building C. On these floors, at each point where hallways cross we will require your staff to complete 100 revolutions of a mallet in a brass singing bowl every three hours. It'll keep Gurus' brainwaves at a low alpha level throughout the event.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Play singing bowls?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"You want the busboys to play singing bowls all day? Are you out of your mind?\"")
             (:template meta-template.customers-dialog)))
           15)
          (((meta (:title . "Can do for a price")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"I mean, it's possible... we can't divert our hotel staff to play music but we could find some local performers to do it, what kind of budget are you looking at for this service?\"")
             (:template meta-template.customers-dialog)))
           14))
         (((meta (:title . "About req: biz intel")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Uh... that's going to involve us working with your IT department. If you could give me their contact information...\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "It has to go through me")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Our guests don't deal with the IT department directly. All guest requests are routed through guest services, which means us. How can I help you?\"")
             (:template meta-template.customers-dialog)))
           11)
          (((meta (:title . "IT number, other Qs?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Here's their number. Did you have any other questions?\"")
             (:template meta-template.customers-dialog)))
           6))
         (((meta (:title . "More info: biz intel")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Well, you see, the issue is that, you see, as part of our spiritual mission it's essential that we be aware of the needs of our Gurus so we can respond to them appropriately.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Get to the point")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Ok, that makes sense, I guess, but what do you want us to do about it?\"")
             (:template meta-template.customers-dialog)))
           13)
          (((meta (:title . "What does that mean?")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Respond to their needs?\"")
             (:template meta-template.customers-dialog)))
           12))
         (((meta (:title . "Yet more: biz intel")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Our internal intelligence service has alerted us to a potential buildup of negative energy within Annapurna. They suspect that a group of our midlevel Gurus are planning to defect to Crystalline Natural Essences and take their downlines with them. This would result in severe karmic pollution along with significant financial losses for Annapurna. In order to prevent this we need an idea of what the Gurus are saying to each other.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "What do you mean?")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"So what are you asking for? What does that entail?\"")
             (:template meta-template.customers-dialog)))
           13))
         (((meta (:title . "Shoe drops: biz intel")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"What it boils down to is that we will require that special listening devices be installed in each of the rooms we've reserved. It's important that we be able to monitor Gurus' conversations in real time.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Listening devices")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Listening devices! Are you serious?\"")
             (:template meta-template.customers-dialog)))
           18)
          (((meta (:title . "Anything to help our guests")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Certainly, anything to help someone booking that many rooms. I'll get it figured out with IT.\"")
             (:template meta-template.customers-dialog)))
           16))
         (((meta (:title . "Say yes to woo: happy guest")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Wonderful, wonderful! Did you have any other questions?\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Yes, back to main")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"I did...\"")
             (:template meta-template.customers-dialog)))
           6)
          (((meta (:title . "More about Annapurna")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"So what kind of company is Annapurna?\"")
             (:template meta-template.customers-dialog)))
           4))
         (((meta (:title . "Say no to woo: annoyed")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Oh, I see. Really going above and beyond in the hospitality department, aren't you?\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Back to main")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"I had other questions...\"")
             (:template meta-template.customers-dialog)))
           6)
          (((meta (:title . "More about Annapurna")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"What kind of business is Annapurna anyway?\"")
             (:template meta-template.customers-dialog)))
           4))
         (((meta (:title . "Say yes to spying: happy")
            (:template meta-template.customers-title))
           (meta (:image . "man-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Excellent, excellent. Don't forget to get us you bank information, you're due for... compensation.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Other questions")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Anyway, I had other questions...\"")
             (:template meta-template.customers-dialog)))
           6)
          (((meta (:title . "About Annapurna")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Anyway, what kind of company is Annapurna?\"")
             (:template meta-template.customers-dialog)))
           4))
         (((meta (:title . "Say no to spying: angry")
            (:template meta-template.customers-title))
           (meta (:image . "man-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"I guess you'll find out how far that attitude takes you in your career. Our needs will be met one way or another.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Other questions")
             (:template meta-template.customers-title))
            (meta
             (:dialog . "\"Thanks for the advice. I had other questions...\"")
             (:template meta-template.customers-dialog)))
           6)
          (((meta (:title . "What kind of company")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Doing business on your level? What kind of company is Annapurna anyway?\"")
             (:template meta-template.customers-dialog)))
           4))
         (((meta (:title . "Spying detail")
            (:template meta-template.customers-title))
           (meta (:image . "man-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Look, maybe you just don't understand how business is done on our level. This is a precaution we're taking for the well-being of our Gurus more than anything. Can you help us help them? If you can work with us you may be qualified for a... personal bonus paid directly.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Sign me up!")
             (:template meta-template.customers-title))
            (meta
             (:dialog . "\"A special bonus? Sign me up! Consider it done!\"")
             (:template meta-template.customers-dialog)))
           16)
          (((meta (:title . "I'll pretend I didn't hear that")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"You're offering me...? I'll pretend I didn't hear that.\"")
             (:template meta-template.customers-dialog)))
           17))
         (((meta (:title . "Recruit 1: four jhanas")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"The jhanas are four essential meditative practices, the four modes of mindfulness, of doing-in-not-doing. You know something... now that you bring this up I'm starting to sense that you have a natural spiritual affinity.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "I feel that way too")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"I feel that way too, could just be an acid flashback though.\"")
             (:template meta-template.customers-dialog)))
           20))
         (((meta (:title . "Recruit 2: natural affinity")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Yes, I can feel that this meeting was fated. It is for moments like this that we walk the paths of samsara. I sense within you the potential to be an Annapurna Guru.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "No offense but...")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Uh, no offense but I should probably just concentrate on the job I'm doing right now.\"")
             (:template meta-template.customers-dialog)))
           24)
          (((meta (:title . "What does a Guru do?")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"So what does a Guru do?\"")
             (:template meta-template.customers-dialog)))
           21))
         (((meta (:title . "Recruit 3: A Guru's role")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"As a Guru your hand will help to balance the scales of maya in the physical world, guiding the unawakened on their journey to cast off the scales of dhamma. You can also become a millionaire in as little as three months. You can be a part of this global shift in consciousness but only if you act now.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Not appropriate")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Uh, I don't think it's appropriate for me to discuss this with you at work.\"")
             (:template meta-template.customers-dialog)))
           24)
          (((meta (:title . "Act now?")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Act now? Why the sense of urgency?\"")
             (:template meta-template.customers-dialog)))
           22))
         (((meta (:title . "Recruit 4: The imperative")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Our upline Gurus have foreseen that in the near future, the souls of humanity will enter a higher vibrational state bringing with it the chance to commune with souls from past cosmic cycles. It is imperative that we use our tools of herbal aromatherapy to raise the consciousness of as many people as possible in the meantime. You have the chance to help us reach this goal.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Pyramid scheme?")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"Is this like one of those pyramid schemes?\"")
             (:template meta-template.customers-dialog)))
           24)
          (((meta (:title . "What would it involve")
             (:template meta-template.customers-title))
            (meta (:dialog . "\"So what's the first step to be a Guru?\"")
             (:template meta-template.customers-dialog)))
           23))
         (((meta (:title . "Recruit 5: The Offer")
            (:template meta-template.customers-title))
           (meta (:image . "girl-relaxed")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"If you enroll as a Guru now you could work for just 15 minutes a day the next two months and make an extra quarter million dollars. All you have to do is recruit your friends and family. You can ask the guests here if they'd like to join too! You can buy our business starter package with an essential oil sampler for just $2500.\"")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Can't afford")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Did you say $2500? How am I supposed to afford that?\"")
             (:template meta-template.customers-dialog)))
           24))
         (((meta (:title . "Recruit no: loser")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Sounds like you're a loser who's just going to keep on losing. The American Dream is for those willing to grab hold of it when opportunity knocks. I can't believe I wasted time talking to you.")
            (:template meta-template.customers-dialog)))
          (((meta (:title . "Thanks a lot")
             (:template meta-template.customers-title))
            (meta
             (:dialog
              . "\"Thanks a lot, in any case I had some questions about your event coming up.\"")
             (:template meta-template.customers-dialog)))
           5))
         (((meta (:title . "Untitled")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Sounds like you're a loser who's just going to keep on losing. The American Dream is for those willing to grab hold of it when opportunity knocks. I can't believe I wasted time talking to you.")
            (:template meta-template.customers-dialog))))
         (((meta (:title . "Untitled")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Sounds like you're a loser who's just going to keep on losing. The American Dream is for those willing to grab hold of it when opportunity knocks. I can't believe I wasted time talking to you.")
            (:template meta-template.customers-dialog))))
         (((meta (:title . "Untitled")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Sounds like you're a loser who's just going to keep on losing. The American Dream is for those willing to grab hold of it when opportunity knocks. I can't believe I wasted time talking to you.")
            (:template meta-template.customers-dialog))))
         (((meta (:title . "Recruit no: loser")
            (:template meta-template.customers-title))
           (meta (:image . "girl-irritated")
            (:template meta-template.customers-image))
           (meta
            (:dialog
             . "\"Sounds like you're a loser who's just going to keep on losing. The American Dream is for those willing to grab hold of it when opportunity knocks. I can't believe I wasted time talking to you.")
            (:template meta-template.customers-dialog))))))
;; :graph-original
#|
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "First node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Knock knock.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to second node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "Who's there?")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1))
         (((meta (:title . "Second node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Bob.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to third node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "Bob who?")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           2))
         (((meta (:title . "Third node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Bob Ross.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to first node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "I'll show you a happy little tree you son of a-")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           0))))
|#
:esgraph-node-template
(quote (((meta (:title . "Untitled node")
               (:fx . :uicc-field) (:type :text :pair :named :block))
         (meta (:code . "")
               (:type :code-area :lang-apl)))))
:esgraph-link-template
(quote (((meta (:title . "Untitled link")
               (:fx . :uicc-field) (:type :text :pair :named :block)))))
:esgraph-node-indices
'(0 1 2)
:esgraph
(setf *esgraph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "Untitled node 1")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←baseManifest myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "To node 2")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1)
          (((meta (:title . "To node 2 second")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1))
         (((meta (:title . "Untitled node 2")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←reduceRadiiLogical myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "To node 3")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           2))
         (((meta (:title . "Untitled node 3")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←reduceSlotConductorsWhole myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "Back to start")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           0))))
:table
(setf *input*
      '(meta (((meta nil (:name . :to-solve) (:title . "? Flow Rate") (:type :trigger))
               (meta 400.0 (:name . :v-0) (:type :field :numeric))
               (meta "STB/d" (:name . :u-0) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "STB/d")))
              ((meta nil (:name . :to-solve) (:title . "? Well Pressure") (:type :trigger))
               (meta 500.0 (:name . :v-1) (:type :field :numeric))
               (meta "psi" (:name . :u-1) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "psi")))
              ((meta nil (:name . :to-solve) (:title . "? Avg. Res. Pres.") (:type :trigger))
               (meta 1500.0 (:name . :v-2) (:type :field :numeric))
               (meta "psi" (:name . :u-2) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "psi")))
              ((meta nil (:name . :to-solve) (:title . "? Permeability") (:type :trigger))
               (meta 50.0 (:name . :v-3) (:type :field :numeric))
               (meta "mD" (:name . :u-3) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "mD")))
              ((meta nil (:name . :to-solve) (:title . "? Formation Thickness") (:type :trigger))
               (meta 25.0 (:name . :v-4) (:type :field :numeric))
               (meta "ft" (:name . :u-4) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Viscosity") (:type :trigger))
               (meta 2.8345143463802374 (:name . :v-5) (:type :field :numeric))
               (meta "cP" (:name . :u-5) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "cP")))
              ((meta nil (:name . :to-solve) (:title . "? Formation Factor") (:type :trigger))
               (meta 1.20 (:name . :v-6) (:type :field :numeric))
               (meta "res-ft^{3}/std-ft^{3}" (:name . :u-6) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "res-ft^{3}/std-ft^{3}")))
              ((meta nil (:name . :to-solve) (:title . "? Well Radius") (:type :trigger))
               (meta 0.5 (:name . :v-7) (:type :field :numeric))
               (meta "ft" (:name . :u-7) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Drainage Radius") (:type :trigger))
               (meta 1500.0 (:name . :v-8) (:type :field :numeric))
               (meta "ft" (:name . :u-8) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Skin Factor") (:type :trigger))
               (meta -1.0 (:name . :v-9) (:type :field :numeric)))
              )
        (:type :series :form :tabular
         )))
