package com.magnumopus.usermanagement.services;

import com.magnumopus.usermanagement.models.Audit;
import com.magnumopus.usermanagement.models.User;
import com.magnumopus.usermanagement.repositories.AuditRepository;
import com.magnumopus.usermanagement.repositories.UserRepository;
import com.magnumopus.usermanagement.utilities.ActionType;
import com.magnumopus.usermanagement.utilities.InputValidator;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
public class UserServiceImpl implements UserService {

    @Resource
    private UserRepository userRepository;

    @Autowired
    private AuditRepository auditRepository;

    public UserServiceImpl(UserRepository userRepository, AuditRepository auditRepository) {
        this.userRepository = userRepository;
        this.auditRepository = auditRepository;
    }

    /***
     * @see com.magnumopus.usermanagement.services.UserService#createUser(User)
     * */
    @Override
    @Transactional
    public User createUser(User user) {
        Audit audit = auditRepository.save(new Audit(1, "t_user", ActionType.CREATE.toString(), "New User created"));
        user.setAudit(audit);
        userRepository.save(user);
        return user;
    }

    /***
     * @see com.magnumopus.usermanagement.services.UserService#fetchUser(int)
     * */
    @Override
    public User fetchUser(int userId) {
        return userRepository.findById(userId).get();
    }

    /***
     * @see com.magnumopus.usermanagement.services.UserService#updateParticularUser(User)
     * */
    @Override
    @Transactional
    public void updateParticularUser(User user) {
        userRepository.save(user);
    }

    /***
     * @see com.magnumopus.usermanagement.services.UserService#getUserList(int, int, int)
     * */
    @Override
    public List<User> getUserList(int start, int end, int totalUserCount) {
        return this.findAllUser();
    }

    /***
     * @see UserService#findAllUser()
     * */
    @Override
    public List<User> findAllUser() {
        List<User> returnList = new ArrayList<>();
        Iterable<User> userList = userRepository.findAll();
        if(userList != null) {
            for (User user: userList) {
                returnList.add(user);
            }
        }

        return returnList;
    }

    @Override
    public User getUserByUserName(String userName) {
        List<User> userList = userRepository.findByUserNameNamedNativeOrmXml(userName);
        User user = null;
        if (userList != null && !userList.isEmpty()) {
            user = userList.get(0);
        }
        return user;
    }

    /***
     * @see com.magnumopus.usermanagement.services.UserService#deleteUser(int)
     * */
    @Override
    public String deleteUser(int userId) {
        String returnMsg = null;
        Optional<User> user = userRepository.findById(userId);
        if (user.get() != null) {
            userRepository.delete(user.get());
            returnMsg = "Deletion Successful";
        } else {
            returnMsg = "User not found";
        }

        return returnMsg;
    }
}
