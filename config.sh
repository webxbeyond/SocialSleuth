# SocialSleuth Configuration File
# This file contains platform definitions and settings for the SocialSleuth script

# Platform Configuration Format:
# [Platform Name]="URL_template|not_found_indicator|additional_headers"
# 
# Variables:
# {username} - Will be replaced with the actual username
# 
# not_found_indicator - Text that appears when profile doesn't exist
# additional_headers - Optional custom headers (separated by semicolon)

# Social Media Platforms
declare -A PLATFORM_CONFIG=(
    # Major Social Networks
    ["Instagram"]="https://www.instagram.com/{username}/|The link you followed may be broken"
    ["Facebook"]="https://www.facebook.com/{username}|not found"
    ["Twitter"]="https://www.twitter.com/{username}|page doesn't exist"
    ["X"]="https://x.com/{username}|page doesn't exist"
    ["LinkedIn"]="https://www.linkedin.com/in/{username}|404"
    ["TikTok"]="https://www.tiktok.com/@{username}|couldn't find this account"
    ["Snapchat"]="https://www.snapchat.com/add/{username}|Sorry! Couldn't find"
    ["WhatsApp"]="https://wa.me/{username}|404"
    
    # Video Platforms
    ["YouTube"]="https://www.youtube.com/user/{username}|Not Found"
    ["YouTube_Channel"]="https://www.youtube.com/c/{username}|Not Found"
    ["Vimeo"]="https://vimeo.com/{username}|404 Not Found"
    ["Twitch"]="https://www.twitch.tv/{username}|Sorry. Unless you've got a time machine"
    ["DailyMotion"]="https://www.dailymotion.com/{username}|404"
    
    # Developer Platforms
    ["GitHub"]="https://www.github.com/{username}|404 Not Found"
    ["GitLab"]="https://gitlab.com/{username}|404"
    ["Bitbucket"]="https://bitbucket.org/{username}|404"
    ["SourceForge"]="https://sourceforge.net/u/{username}/profile/|404"
    ["CodePen"]="https://codepen.io/{username}|404"
    ["Replit"]="https://replit.com/@{username}|404"
    ["Kaggle"]="https://www.kaggle.com/{username}|404"
    
    # Professional Networks
    ["AngelList"]="https://angel.co/u/{username}|404 Not Found"
    ["Behance"]="https://www.behance.net/{username}|404 Not Found"
    ["Dribbble"]="https://dribbble.com/{username}|404"
    ["Stack_Overflow"]="https://stackoverflow.com/users/{username}|404"
    ["ResearchGate"]="https://www.researchgate.net/profile/{username}|404"
    
    # Content Platforms
    ["Medium"]="https://medium.com/@{username}|404"
    ["DeviantART"]="https://{username}.deviantart.com|404"
    ["Tumblr"]="https://{username}.tumblr.com|404"
    ["Blogger"]="https://{username}.blogspot.com|404"
    ["WordPress"]="https://{username}.wordpress.com|Do you want to register"
    ["Substack"]="https://{username}.substack.com|404"
    ["Wattpad"]="https://www.wattpad.com/user/{username}|404"
    
    # Visual Platforms
    ["Pinterest"]="https://www.pinterest.com/{username}|?show_error"
    ["Flickr"]="https://www.flickr.com/people/{username}|Not Found"
    ["500px"]="https://500px.com/p/{username}|404 Not Found"
    ["Unsplash"]="https://unsplash.com/@{username}|404"
    ["VSCO"]="https://vsco.co/{username}|404"
    
    # Music Platforms
    ["Spotify"]="https://open.spotify.com/user/{username}|404"
    ["SoundCloud"]="https://soundcloud.com/{username}|404 Not Found"
    ["Bandcamp"]="https://{username}.bandcamp.com|404"
    ["Last.fm"]="https://last.fm/user/{username}|404"
    ["Mixcloud"]="https://www.mixcloud.com/{username}|error-message"
    ["Apple_Music"]="https://music.apple.com/profile/{username}|404"
    
    # Gaming Platforms
    ["Steam"]="https://steamcommunity.com/id/{username}|The specified profile could not be found"
    ["Xbox"]="https://account.xbox.com/en-us/profile?gamertag={username}|404"
    ["PlayStation"]="https://psnprofiles.com/{username}|404"
    ["Twitch"]="https://www.twitch.tv/{username}|Sorry. Unless you've got a time machine"
    ["Discord"]="https://discord.com/users/{username}|404"
    ["Roblox"]="https://www.roblox.com/users/profile?username={username}|404"
    ["Epic_Games"]="https://www.epicgames.com/site/en-US/user-search?text={username}|No users found"
    
    # Forums & Communities
    ["Reddit"]="https://www.reddit.com/user/{username}|404"
    ["Disqus"]="https://disqus.com/by/{username}|404"
    ["Quora"]="https://www.quora.com/profile/{username}|404"
    ["HackerNews"]="https://news.ycombinator.com/user?id={username}|No such user"
    ["ProductHunt"]="https://www.producthunt.com/@{username}|404"
    
    # Business & Finance
    ["Crunchbase"]="https://www.crunchbase.com/person/{username}|404"
    ["F6S"]="https://www.f6s.com/{username}|404"
    ["Patreon"]="https://www.patreon.com/{username}|404"
    ["Kickstarter"]="https://www.kickstarter.com/profile/{username}|404"
    ["GoFundMe"]="https://www.gofundme.com/{username}|404"
    
    # Adult Content (Optional - uncomment if needed)
    # ["OnlyFans"]="https://onlyfans.com/{username}|404"
    # ["Pornhub"]="https://www.pornhub.com/users/{username}|404"
    
    # Regional/International
    ["VK"]="https://vk.com/{username}|404"
    ["OK"]="https://ok.ru/{username}|404"
    ["Weibo"]="https://weibo.com/n/{username}|404"
    ["QQ"]="https://user.qzone.qq.com/{username}|404"
    ["Line"]="https://timeline.line.me/user/{username}|404"
    
    # Dating Platforms
    ["Tinder"]="https://tinder.com/@{username}|404"
    ["Bumble"]="https://bumble.com/{username}|404"
    ["OkCupid"]="https://www.okcupid.com/profile/{username}|404"
    ["Match"]="https://www.match.com/{username}|404"
    
    # Shopping & Commerce
    ["eBay"]="https://www.ebay.com/usr/{username}|eBay Profile - error"
    ["Etsy"]="https://www.etsy.com/people/{username}|404"
    ["Amazon"]="https://www.amazon.com/gp/profile/amzn1.account.{username}|404"
    
    # Learning Platforms
    ["Coursera"]="https://www.coursera.org/user/{username}|404"
    ["Udemy"]="https://www.udemy.com/user/{username}|404"
    ["Khan_Academy"]="https://www.khanacademy.org/profile/{username}|404"
    ["Codecademy"]="https://www.codecademy.com/profiles/{username}|404"
    
    # Other Platforms
    ["Gravatar"]="https://en.gravatar.com/{username}|404"
    ["About.me"]="https://about.me/{username}|404"
    ["Keybase"]="https://keybase.io/{username}|404 Not Found"
    ["Linktree"]="https://linktr.ee/{username}|404"
    ["Carrd"]="https://{username}.carrd.co|404"
)

# Breach Database APIs
declare -A BREACH_APIS=(
    ["HudsonRock"]="https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-username?username={username}"
    ["HaveIBeenPwned"]="https://haveibeenpwned.com/api/v3/breachedaccount/{username}"
)

# Default Settings
DEFAULT_TIMEOUT=10
DEFAULT_PARALLEL_JOBS=15
DEFAULT_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
DEFAULT_OUTPUT_DIR="results"

# Advanced Detection Patterns
declare -A DETECTION_PATTERNS=(
    ["profile_exists"]="profile|user|account|@"
    ["profile_missing"]="404|not found|doesn't exist|page not found|user not found|account not found"
    ["blocked_access"]="403|forbidden|access denied|blocked"
    ["rate_limited"]="429|rate limit|too many requests"
)

# Custom Headers for Specific Platforms
declare -A CUSTOM_HEADERS=(
    ["Instagram"]="X-Requested-With: XMLHttpRequest"
    ["TikTok"]="Accept: application/json"
    ["LinkedIn"]="X-Requested-With: XMLHttpRequest"
)

# Platform Categories for Organized Scanning
declare -A PLATFORM_CATEGORIES=(
    ["social"]="Instagram Facebook Twitter LinkedIn TikTok Snapchat"
    ["developer"]="GitHub GitLab Bitbucket Stack_Overflow CodePen"
    ["content"]="YouTube Medium DeviantART Tumblr Pinterest"
    ["gaming"]="Steam Xbox PlayStation Twitch Discord Roblox"
    ["professional"]="LinkedIn AngelList Behance Dribbble"
    ["music"]="Spotify SoundCloud Bandcamp Last.fm"
)

# Scoring System for Profile Confidence
declare -A CONFIDENCE_INDICATORS=(
    ["high"]="profile picture|bio|posts|followers|verified"
    ["medium"]="created|joined|member since"
    ["low"]="empty profile|no posts|default avatar"
)
