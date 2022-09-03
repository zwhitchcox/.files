from marionette_driver.keys import Keys
from marionette_driver.marionette import Marionette,ActionSequence
import time

def send_keys(client, keys):
    for key in range(0, len(keys)):
        ActionSequence(client, "key", "1").send_keys(keys[key]).perform()
        time.sleep(0.2)

client = Marionette('localhost', port=2828)
client.start_session(timeout=2)
# client.navigate("https://accounts.firefox.com/?context=fx_desktop_v3&entrypoint=fxa_app_menu&action=email&service=sync")
# time.sleep(1)
# ActionSequence(client, "key", "1").send_keys("zwhitchcox@gmail.com" + Keys.ENTER).perform()
# time.sleep(1)
# ActionSequence(client, "key", "1").send_keys("Tiger#508" + Keys.ENTER).perform()
print(client.session_capabilities)
exit()

gmail = client.open(type="tab", focus=True)
client.switch_to_window(gmail["handle"])
client.navigate("https://accounts.google.com/signin/v2/identifier?service=mail&sacu=1&rip=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin")
time.sleep(1)
send_keys(client, "zwhitchcox@gmail.com")
time.sleep(1)
ActionSequence(client, "key", "1").send_keys(Keys.ENTER).perform()
time.sleep(1)
#ActionSequence(client, "key", "1").send_keys("Tiger#508" + Keys.ENTER).perform()
