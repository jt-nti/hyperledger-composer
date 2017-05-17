(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else   
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �yY �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/�Ht7�V����9ݸ�>Y�Wn��!��S��i�xEiyx��G�	�"� (����9�y�M���Z��:�����r���C�>���i7���`���2��q��)�$*���������@�X�BH%�2�f�oީ.�?J�T%�2p���>��+���p��	�������?���:N�W������_��k�?�xv���'=�(`� ����Z�{��X@P�������<��8^���k��P|��/f��9��`���M����4��됄�{.�P������4E2�k;E�(����}�ث�s�!������?^8���?^|�RC��?\�_��Y������.��km�:�AJ��&���ĻlR_�L~o�Q�k�VCٴ��MfBj��|����F_!X�b3h�q<u��ؤ������D�)�F=D!���t��S�N'[	��n C�T��>am�}yq �HqՏl���_�k߾A�Ɗ���k�������Eӥ��;���0�Z�+%�������ď<���8�T�h��K��ϋ�!K2_��[�/�|��y�vC��eMYJ|2�{[f���-�e�6���|��i� f\�hY�%����98��R<��甶�I�=o݈L,C*�v��v�:���,���5$g�H�9QW s��D�݆�p��~|w�z\��P��-ƣVύܝ�#H0D\�\9^���H0�"Mޫ����Ď��L�4��x :t�94��:q���[{(���\C0��)�p#ica���1���8?n�.�B~�A�'�xh���Tn�pJ�۟i��B�Ӈ�B"N�U1"�6o��b�IdJ؍�i�v�k���2uN�em
h�	���\2T�p;ByWZj�����՝)�̵����y
 ���	����&E��@���~��hp�~�����saI
&oE�#]��EY�.2&����N�yX12[�FѦI����(�7͕��d(D�$�8�e�G �C'r����"�.a�E��,��~����a�];�Cn9I[RMM/F]}�d	�,�9�x�,z�4����������gf9�%��M�7��{�� �������Q�S�U�G��?��t��e�5�g�;���@=2̛흺_���@�8��В��X>̐#q���^B�Џ��
|Hʑ�z E�����di���2s��I���:?�2��4]�!�l��b��p��#v�D���[�NyM1GkH���5q"5q1u{����~o�yl��W�y.�V��
������2t����[���˶:U �U��ք9P�m�0<Z GZoi�rf�m qy���+ ���TɌ�\�A����}� ����堛��>�u�^��[��kSR�G�D������:��u�E��`f����d_��8�#�f5�7�~�&��� 7ؽߤی�	��97�~&׵d:\M�6��C%�u���|����]����'I���("��9�_����T��e���+�����\{����c/������/��3�*��T�?U�ϯ�ҧ� 'Q���f������); 	h�e0�u(��%�q�#�*���B����Q�E���W.����=q�w4)h��Hc=A]f��\�������F��/���ec�m+��qCN���o�|�-[ʰ�l��a��%ǜ�L7�t;��=�csc����
p;�nX@�$�m��=�������g��T��������?X���@��W��U���߻��g��T�_
>H���?$����J������ߛ9	�G(L���.@^����`�����%��7kpl�L̇0�н�4��ށ
��*@�tb�I�7���txs�;��H��H�\u:w��f�z3�7l�k���AS�(^��b�.u�A��U;Ǝ�Y�{�u�9Ҷxd\�ǈ�#}/8���sr��8m�<f	��i��� =����4�+qz��	'�h>Cm��LBDy�Z|g����haڳ'�&Te p�� j��a���ЬG����l�]wZ����Ҟ)-K�z��͎���#JH;#)ɜ�H^�n�@B�<�+���z�Z��|����?3����|��?#����RP����_���=�f����>�r�G���Rp��_��q1�����T�_���.���(��@�"�����%��16���ӏ:��O8C������빁[�8�(���H��>��,IRv�����_��ЅJ��pA��ʄ]�_�V�byñ9�5�f{�9Ҫ�l�m��Rx1�%���q�N+)54$wm'���ǫ{���(ǌ��v��7pD���������=n2�L?�SJN�v�*���x<�����?�b���j���A���y
�;�����rp��o�/S
��'�j������A������r��8�U�/)����^,Őj�o)��0}�����������Ʌ��bD�b�cۤ��K�.F!�K�,f{X�������L8��2��VE���_���#�������?]D��� �D4L^L�ݠ�nci�x�s�X鮑&����V�p�e���+�au]��S��0"7�3�`��(�|�G�|F�T��Nc�[����&���k��3[��ލ���/m}��GЕ�W
~�%���u��+����I��A���B�D���C	�i�7Q����W^��j�<���ϝ���k�KX0�}C~v��x���?K�ߟ����q����r1��Zo�H_������~�9���9���A��=zд�æ�[&N>��)��/��+݅����A?�$��}�؄q��1r-��f��Ex�p�LNp�ɬ'��x��bs5�9jo�EsI�٠��`�uF9��z��2<�Q&�=b��Mb����k�Mba΅�x��9ޭ�+�F��5a��7�STY�M9�S�Kw*�vg<6� n-�y��<�K�In{.���}�?�� �'�)gSs��wu��{
mE6��l�q�s�2�)a�l�i��@�=��a�Sb3�=)�h���g�O�֪�Ys�P��ϋ�H���v�w��8Q���෰�)����&|���An���(C������(U��^
޶����c��_��n�$��T�wx��#�����2?yf(?��G�t���@�O��@�q[z-PS �]��'n��k��<�������nJJ�Xڢ��#[����m�5����Ԕh�;ķf*Ǯ�	C:�͘$s�Z��������%��/�I_M��==���A��}�R{���Ț���	�H�6k��y�^wӾ�R󬑬�R��S2���k�g�`�r����߃�N�Ѱ	#$�{Da�6������H���q���MU��෰��g�������Z�����g���������������j��Z����)0���U��\.��������Q�]��e�����+��s���X�����?�ￕ�������1%Q�q(�%\���"��� p���G	�X�
p�G(��������
e����G�PH��S
.����)�rrط̩�f�/0DhN=���l��y�-Z����?� ��q[iXW��E��5��ľ����UQRs̡��+8��)L�Z:Yg�Q�&���F}���ش������ݹ��?J�̿�G�����?�#���_�~��l�4+����_�_���v���W�Vsm�x�զ��_k�}�����N:u�\�뎡n(�
�F��+{�L��w��v����_�ϕ�jW5	p������U�o��v��zul�������:�^ǿh�$����)������ֲI�ʭ�����Q���U�r}\����ꓟ���}��\���_V���W�rj�_O�&�_�+���x���}t_r��׷��m/��t�7K;*F�k��Unm�ۑ��]�+���Ec���.�7Quй��}CT� �b���>�y���ڗ��h4�·�l_+*ɝ��sG�w�:��4̮o_��Yz���vy�Q�=Y��=���jiA֟� ʒ;���
�N����#�j/��_�X�I"}�����<<��>ΐ������yew�����ݮ�������*�~�����=�����E�����wjj���2����'k8�{=��ԅ��z�q������Hj�Z�a�MX�@��)��x>���b����pD�=u���)��p,s�b໺x�7���]A�G"?0DCV�����-��eUqd|[��q��sF�ue���YNw_a�����)�n��ْ��N��7{b1n�����g�����u���p�\υˡ��2f��{�t]�ҡ"]�n;]�ukO׵ۺ���;1AM�	&����?1�OJ�F��|P	4bD!&������l;g�p� ���=]�^����=���{�G/6�Θ#���ܔ�A	���]!�,�L��H
�FÃ�xA�H2���.%ӑx׭mY;&�:z��"���2�N�q���ʹ�fet,����D�y�'����6!�v1a\ȇm�wTeI�{:884��6�����D�8�����[f&M7�� �Z-�m����L�,��V4]7um����8cg֫���;�$(�>��Lv�C�-d�4E��q	�
_e;R���,�7�h}0�׌3�U�=4��H�̪��5Π˰Ѳ��f�����!�PZ����YG�W�VE��{���Y^�M��h�|��t��o�t�M�)r8]�ɆSN���98�������trb��;�G�_'W�A���EEb�*wZ�E�}��\���c��j���e�u���_�2�&�t*i��H�s�ou�C֑�����sFO�T�x֜��H�2�4ҹ�+�5�o��2�+Q�5N�)F�`t������Շ��|m]p\r����T��2��c����M�z�b����\4([�(E������@]�9�Z�+7��9��ˑ~�S{����|U2�-�
�ÍF1���|vϹ����$�B��ɏ9)�:b!Cf<�Kp���:��2b�f�mN�4��޴��tx��Kǧ�}�a�+#��U{I6ta-*���B��.dy��>G����89���U�t?�}��C�y�(�sy�`�؟O>��{��w������Qc����?��������O��8x�Nl�Z{�ߏ��j絖J\x`���.��@�`,��E�U�uc�^�G�׳��V]����*���#��C9=�����Cgoo�vǙ_���ح��wO<����ڥG��9�
<C��J7����9�5�@8�C'��� ��š����9p�q��9���'��\���H�A���>=�Ծ�_���d}����Y�<0"�Ὠ�%�,ף��m��$^�0{����� ��a���6���e�z�����`#G$7C�6�%�n�3�,�Q��!�n�_��[��!��L��P;e��k`�4��Wɝ.��i2_�Q,S�׃���l���A�#pF��Ɇn�R�$�l����0GaJ����&j|?Mg��hG�X�)�A�/�����,
�L:;�+��f�(�ȄT*{j�l�G	�F)/�0,��-!&$=���,$�������C|��Ԕ'��z)D�!X.�G>e3am&�̈́]�	=} �n����E��Ԧ�:�Z�z�C�kvzK�.�����JȺUq0���h��d#n<(owœ�LR�n��2W��p_�#^���2A4�'Q��o5z��	%�L��6��|B"��CV�v�4�.�`�A"ԎdX��������+�CV�ل��l����A�
Amk�r<B�S�H��j���q�d%�U:�>�v�j�����D�@�)�apw=��cLd�m4�}e	��,ـuFY�ܙ�\w@
d���p*%����N488�������g�V4�v��6����P>�S-�IqJt���/B��ʠ
����g$:�%*B��*�h��1y<ӒRsʲGxFv��DU��h�7$	����V��9�`W'���p�I�8b*�`X-�;Q����J%#5?�k2�|�PM�}����
�ﭲ�)K����W��
�Ec=��|���Q�t�Y $(q����;)t�Z3�]���_I�|/5,��q%Z��vr�İR�������HLj�	 '܇S����I�A��j�,��7¤\�L�c�9e�#<#�TY��&��0��Ū�>-�T�{�,�+�k�%��7�p�9D���I��ɾ�T�6!�}�B�3#٤Ȗ#� ��$�����8m����l�m5�m�n�4'
�)��6�j�G�skWB�tJ�{b튍3�uӯ�V&A �.{�T�u��t��+��J�l�PUm���mN4B�r��]�v{]M���!T�����7�n�n7��+m\�F'7�7��B���j����AkSU]O�g���Ѳ��֡S�&K�%�ך��Ԇ<t3tz�?��s�هvX��:�,tf�*L~���d.��0�J���r��z]�Z�qL�gu�%3>1-3y��ʁ�;N㊢�Ũ�g�C/CF`Ō�C�C�.��DY5>�i�: �ڌ��?�#�_�[�ȍ������[����w˳_
엂�_
?p�-<���[$��3�.V�|+���le��}�AK	����Xt0�梃Ѡd�AO���`iς�Gu��I���iL7k� �=�w�{�1��7=4E��!�)5�Eҫz؈�EX)�E�@8R����hőh��~����WH�n!8�Ŕ�h^wn�u:�q%_�8Vh�c�rhd�:�����ᑠ�6���ӘI��ݣ&�C�±DM�05:D��g���ꪷC�fj9�i�:F��|>��O(�*q�2��T�q6�AZ��se�u�7�76���6D;�O�bB�%�[$��yյn��i
�$u�-��r�ǥ�V�c<��q8m㰍�6��X׮�t7t��T�2�\�6���c2�c�3���<�{�;t�[�2\��2����}���^���1�������ܗ�ò#i�Hڪ�Hf*8�6J�J)7p�K2�:�e؜�|�����b�KQ���`��>��D�Q�"�V�QPd�YS�՟c�w��Fm*	LL);q1D�A0�L��Ni��r&��tP8��Ѳ��/+]n�4��������/
�K)	�bB8Z��썅��Cvc!D����A���0!RcKM���pp�(O���nAy��._ڙ�+�Ŷ;"��|��R<���Byq�Y&�P�l�3� BW��B{���Ė��9@7Y����R.��t���V/�¾K;��a��a���q��q�F�Vr�܇v�fr��Z)$�B�m�"��ۅ�6e5��2m�õ;�-\���n�_G4�JE�5���^�\?���σ�q��$��-�M����Lw{}�\�W�Mҟ�I�t���^���G~��V�;>��/륧��]_z�/���q�Zc?�������f�ٴp��1�q ���]������%���g����Ko��� �x���M|󦿾��W�? z�$��8x*�~p�ڕޯ��䊞n��h:Q�m@g߈��O~�/6~'����_/��׿�'��)�����4E�|�	�9K�|զv��N��i�l��M����߿��i; mS;mj�M��}6�g{?P;ͷ��|�� U�B����z��&�&�A�-"�N21����L��1��=��_��^��&��<ۭ�y��T�S��3���6���gp��X���`9_�MM�Y�i�sf�h�=gƞ`O�����a�e�3s���G�s9f�\8�0�!Bk��6�]��1�9��_ju��b��Nv������M���q�  